local ksm = (import 'kube-state-metrics/kube-state-metrics.libsonnet') +
            {
              local ksm = self,
              name:: 'kube-state-metrics',
              namespace:: 'monitoring',
              version:: 'v1.9.5',
              image:: 'docker.io/charlieegan3/ksm-arm:' + ksm.version,
              serviceMonitor: {
                apiVersion: 'monitoring.coreos.com/v1',
                kind: 'ServiceMonitor',
                metadata: {
                  name: ksm.name,
                  namespace: ksm.namespace,
                  labels: ksm.commonLabels,
                },
                spec: {
                  jobLabel: 'app.kubernetes.io/name',
                  selector: {
                    matchLabels: ksm.commonLabels,
                  },
                  endpoints: [
                    {
                      port: 'http-metrics',
                      interval: '30s',
                      scrapeTimeout: '30s',
                      honorLabels: true,
                      relabelings: [
                        {
                          regex: '(pod|service|endpoint|namespace)',
                          action: 'labeldrop',
                        },
                      ],
                    },
                    {
                      port: 'telemetry',
                      interval: '30s',
                    },
                  ],
                },
              },
            };

{ ['ksm-' + name]: ksm[name] for name in std.objectFields(ksm) }
