// import kubernetes types
local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local sts = k.apps.v1.statefulSet;
local sts_container = sts.mixin.spec.template.spec.containersType;
local deployment = k.apps.v1.deployment;
local dep_container = deployment.mixin.spec.template.spec.containersType;
local serviceaccount = k.core.v1.serviceAccount;
local ingress = k.extensions.v1beta1.ingress;

// generate kube-thanos resources
local kt =
  (import 'kube-thanos/kube-thanos-querier.libsonnet') +
  (import 'kube-thanos/kube-thanos-store.libsonnet') +
  (import 'kube-thanos/kube-thanos-compactor.libsonnet') +
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
      compactor+: {
        statefulSet+: {
          spec+: {
            template+: {
              spec+: {
                serviceAccountName: 'thanos-compactor',
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
      },
      store+: {
        statefulSet+: {
          spec+: {
            template+: {
              spec+: {
                serviceAccountName: 'thanos-store',
                containers: [
                  super.containers[0] {
                    env+: [
                      {
                        name: 'GOOGLE_APPLICATION_CREDENTIALS',
                        value: '/vault/secrets/key.json',
                      },
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
      },
    },
  };


// Extras
// * create an ingress for the querier
local querier_ingress = ingress.new() +
                        {
                          metadata: {
                            annotations: {
                              'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
                              'kubernetes.io/ingress.class': 'nginx',
                              'nginx.ingress.kubernetes.io/auth-signin': 'https://auth.charlieegan3.com/oauth2/start?rd=https://thanos.charlieegan3.com',
                              'nginx.ingress.kubernetes.io/auth-url': 'https://auth.charlieegan3.com/oauth2/auth',
                            },
                            name: 'thanos-querier',
                            namespace: 'monitoring',
                          },
                          spec: {
                            rules: [
                              {
                                host: 'thanos.charlieegan3.com',
                                http: {
                                  paths: [
                                    {
                                      backend: {
                                        serviceName: 'thanos-querier',
                                        servicePort: 9090,
                                      },
                                      path: '/',
                                    },
                                  ],
                                },
                              },
                            ],
                            tls: [
                              {
                                hosts: [
                                  'thanos.charlieegan3.com',
                                ],
                                secretName: 'thanos-tls',
                              },
                            ],
                          },
                        };

// Output the merged configuration of selected components
{ ['thanos-store-' + name]: kt.thanos.store[name] for name in std.objectFields(kt.thanos.store) } +

{ ['thanos-querier-' + name]: kt.thanos.querier[name] for name in std.objectFields(kt.thanos.querier) } +
{ 'thanos-querier-ingress': querier_ingress }

{ ['thanos-compactor-' + name]: kt.thanos.compactor[name] for name in std.objectFields(kt.thanos.compactor) }
