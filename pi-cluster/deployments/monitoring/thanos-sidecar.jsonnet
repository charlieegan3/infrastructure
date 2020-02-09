local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local service = k.core.v1.service;
local servicePort = k.core.v1.service.mixin.spec.portsType;

{
  _config+:: {
    versions+:: {
      thanos: '4495d094499d5aba093d12bb0ff63df1',
    },
    imageRepos+:: {
      thanos: 'charlieegan3/thanos-arm',
    },
    thanos+:: {
      objectStorageConfig: {
        key: 'thanos.yaml',
        name: 'thanos-objstore-config',
      },
    },
  },
  prometheus+:: {
    // Add the grpc port to the Prometheus service to be able to query it with the Thanos Querier
    service+: {
      spec+: {
        ports+: [
          servicePort.newNamed('grpc', 10901, 10901),
        ],
      },
    },
    prometheus+: {
      spec+: {
        thanos+: {
          version: $._config.versions.thanos,
          baseImage: $._config.imageRepos.thanos,
          objectStorageConfig: $._config.thanos.objectStorageConfig,
        },
      },
    },
  },
}
