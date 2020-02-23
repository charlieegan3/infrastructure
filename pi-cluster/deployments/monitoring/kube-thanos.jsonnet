local t = (import 'kube-thanos/thanos.libsonnet');

local commonConfig = {
  config+:: {
    local cfg = self,
    namespace: 'monitoring',
    version: 'v0.10.1',
    image: 'charlieegan3/thanos-arm:4495d094499d5aba093d12bb0ff63df1',
    objectStorageConfig: {
      name: 'thanos-objstore-config',
      key: 'thanos.yaml',
    },
    volumeClaimTemplate: {
      spec: {
        accessModes: ['ReadWriteOnce'],
        resources: {
          requests: {
            storage: '2Gi',
          },
        },
      },
    },
  },
};

local c = t.compact + t.compact.withVolumeClaimTemplate + t.compact.withServiceMonitor + commonConfig + {
  config+:: {
    name: 'thanos-compact',
    replicas: 1,
  },
} + {
  statefulSet+: {
    spec+: {
      template+: {
        spec+: {
          containers: [
            super.containers[0] {
              args: [
                'compact',
                '--wait',
                '--retention.resolution-raw=1h',
                '--retention.resolution-5m=30d',
                '--retention.resolution-1h=180d',
                '--objstore.config=$(OBJSTORE_CONFIG)',
                '--data-dir=/var/thanos/compactor',
              ],
              resources+: {
                requests: { cpu: '100m', memory: '100Mi' },
                limits: { cpu: '1', memory: '1Gi' },
              },
            },
          ],
        },
      },
    },
  },
};

local s = t.store + t.store.withVolumeClaimTemplate + t.store.withServiceMonitor + commonConfig + {
  config+:: {
    name: 'thanos-store',
    replicas: 1,
  },
} + {
  statefulSet+: {
    spec+: {
      template+: {
        spec+: {
          containers: [
            super.containers[0] {
              args: [
                'store',
                '--data-dir=/var/thanos/store',
                '--grpc-address=0.0.0.0:10901',
                '--http-address=0.0.0.0:10902',
                '--objstore.config=$(OBJSTORE_CONFIG)',
              ],
              resources+: {
                requests: { cpu: '100m', memory: '100Mi' },
                limits: { cpu: '1', memory: '1Gi' },
              },
            },
          ],
        },
      },
    },
  },
};

local q = t.query + t.query.withServiceMonitor + commonConfig + {
  config+:: {
    name: 'thanos-query',
    replicas: 1,
    stores: [
      'dnssrv+_grpc._tcp.%s.%s.svc.cluster.local' % [service.metadata.name, service.metadata.namespace]
      for service in [s.service]
    ],
    replicaLabels: ['prometheus_replica', 'rule_replica'],
  },
} + {
  deployment+: {
    spec+: {
      template+: {
        spec+: {
          containers: [
            // this allows prometheus sidecars to be used as stores for recent data too
            super.containers[0] {
              args+: ['--store=dnssrv+_grpc._tcp.prometheus-k8s.monitoring.svc.cluster.local'],
              resources+: {
                requests: { cpu: '100m', memory: '100Mi' },
                limits: { cpu: '1', memory: '1Gi' },
              },
            },
          ],
        },
      },
    },
  },
};

// TODO disabled while testing block upload
// { ['thanos-compact-' + name]: c[name] for name in std.objectFields(c) } +
{ ['thanos-store-' + name]: s[name] for name in std.objectFields(s) } +
{ ['thanos-query-' + name]: q[name] for name in std.objectFields(q) }
