local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local utils = import 'utils.libsonnet';
local vars = import 'vars.jsonnet';

{
  _config+:: {
    namespace: 'monitoring',

    urls+:: {
      prom_ingress: 'prometheus.' + vars.suffixDomain,
      alert_ingress: 'alertmanager.' + vars.suffixDomain,
      grafana_ingress: 'grafana.' + vars.suffixDomain,
      grafana_ingress_external: 'grafana.' + vars.suffixDomain,
    },

    prometheus+:: {
      names: 'k8s',
      replicas: 1,
      namespaces: ['default', 'kube-system', 'monitoring'],
    },

    alertmanager+:: {
      replicas: 1,
    },

    kubeStateMetrics+:: {
      collectors: '',  // empty string gets a default set
      scrapeInterval: '30s',
      scrapeTimeout: '30s',

      baseCPU: '100m',
      baseMemory: '150Mi',
      cpuPerNode: '2m',
      memoryPerNode: '30Mi',
    },
  },

  prometheus+:: {
    // Add option (from vars.yaml) to enable persistence
    local pvc = k.core.v1.persistentVolumeClaim,
    prometheus+: {
      spec+: {
               replicas: $._config.prometheus.replicas,
               retention: '15d',
               externalUrl: 'http://' + $._config.urls.prom_ingress,
             }
             + (if vars.enablePersistence.prometheus then {
                  storage: {
                    volumeClaimTemplate:
                      pvc.new() +
                      pvc.mixin.spec.withAccessModes('ReadWriteOnce') +
                      pvc.mixin.spec.resources.withRequests({ storage: '20Gi' }),
                    // Uncomment below to define a StorageClass name
                    //+ pvc.mixin.spec.withStorageClassName('nfs-master-ssd'),
                  },
                } else {}),
    },
  },

  // Override deployment for Grafana data persistence
  grafana+:: if vars.enablePersistence.grafana then {
    deployment+: {
      spec+: {
        template+: {
          spec+: {
            volumes:
              std.map(
                function(v)
                  if v.name == 'grafana-storage' then
                    {
                      name: 'grafana-storage',
                      persistentVolumeClaim: {
                        claimName: 'grafana-storage',
                      },
                    }
                  else v,
                super.volumes
              ),
          },
        },
      },
    },
    storage:
      local pvc = k.core.v1.persistentVolumeClaim;
      pvc.new() +
      pvc.mixin.metadata.withNamespace($._config.namespace) +
      pvc.mixin.metadata.withName('grafana-storage') +
      pvc.mixin.spec.withAccessModes('ReadWriteOnce') +
      pvc.mixin.spec.resources.withRequests({ storage: '2Gi' }),
  } else {},

  grafanaDashboards+:: $._config.grafanaDashboards,
}
