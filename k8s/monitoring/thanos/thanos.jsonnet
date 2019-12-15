// import kubernetes types
local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local sts = k.apps.v1.statefulSet;
local sts_container = sts.mixin.spec.template.spec.containersType;
local deployment = k.apps.v1.deployment;
local dep_container = deployment.mixin.spec.template.spec.containersType;
local serviceaccount = k.core.v1.serviceAccount;

// generate kube-thanos resources
local kt =
  (import 'kube-thanos/kube-thanos-querier.libsonnet') +
  (import 'kube-thanos/kube-thanos-store.libsonnet') +
  {
    thanos+:: {
      // This is just an example image, set what you need
      image:: 'quay.io/thanos/thanos:v0.9.0',
      objectStorageConfig+:: {
        name: 'thanos-objstore-config',
        key: 'thanos.yaml',
      },

      querier+: {
        deployment+: {
          spec+: {
            template+: {
              spec+: {
                containers: [
                  // this allows prometheus sidecars to be used as stores for recent data too
                  super.containers[0] {
                    args+: ['--store=dnssrv+_grpc._tcp.prometheus-operated.monitoring.svc.cluster.local'],
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
      },
      store+: {
        statefulSet+: {
          spec+: {
            template+: {
              spec+: {
                serviceAccountName: 'thanos-store',
                containers: [
                  super.containers[0] {
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
      },
    },
  };


// Thanos Store Extras
// * create an annotated service account for workload ID
local store_sa = serviceaccount.new('thanos-store') +
                 serviceaccount.mixin.metadata.withAnnotations({
                   'iam.gke.io/gcp-service-account': 'thanos@charlieegan3-cluster.iam.gserviceaccount.com',
                 });

// Output the merged configuration of selected components
{ ['thanos-store-' + name]: kt.thanos.store[name] for name in std.objectFields(kt.thanos.store) } +
{ 'thanos-store-serviceaccount': store_sa } +

{ ['thanos-querier-' + name]: kt.thanos.querier[name] for name in std.objectFields(kt.thanos.querier) }
