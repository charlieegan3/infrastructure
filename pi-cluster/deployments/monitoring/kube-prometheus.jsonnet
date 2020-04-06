local ingress = import 'ingress.jsonnet';

local kp = (import 'kube-prometheus/kube-prometheus.libsonnet')
           + (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet')
           + (import 'kube-prometheus/kube-prometheus-kops-coredns.libsonnet')
           + (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet')
           + (import 'kube-prometheus/alertmanager/alertmanager.libsonnet')
           // Use custom sidecar config with arm image
           + (import 'thanos-sidecar.jsonnet')
           // Use http Kubelet targets. Comment to revert to https
           + (import 'kube-prometheus/kube-prometheus-insecure-kubelet.libsonnet')
           // Include the arm exporter
           + (import 'arm_exporter.jsonnet')
           // Load K3s customized module
           + (import 'k3s-overrides.jsonnet')
           // Base stack is loaded at the end to override previous definitions
           + (import 'base_operator_stack.jsonnet')
           // Load image versions last to override default from modules
           + (import 'image_sources_versions.jsonnet') +
           {
             _config+:: {
               grafana+:: {
                 datasources: [],  // populated from secret
                 config: {
                   sections: {
                     'auth.anonymous': {
                       enabled: true,
                       org_role: 'Admin',
                     },
                   },
                 },
               },
             },
             grafanaDashboards: {
               'k8s.json': (import 'dashboards/k8s.json'),
               'finance.json': (import 'dashboards/finance.json'),
             },
             prometheusAlerts+:: {
               groups: std.map(
                 function(group)
                   // todo, work out why the original expr sets the path?
                   if group.name == 'kubernetes-system-kubelet' then
                     group {
                       rules: std.map(
                         function(rule)
                           if rule.alert == 'KubeletDown' then
                             rule {
                               expr: 'absent(up{job="kubelet"} == 1)',
                             }
                           else
                             rule,
                         group.rules
                       ),
                     }
                   // not running in k3s
                   else if group.name == 'kubernetes-system-controller-manager' then
                     group { rules: [] }
                   // not running in k3s
                   else if group.name == 'kubernetes-system-scheduler' then
                     group { rules: [] }
                   // some jobs run less than once an hour
                   else if group.name == 'kubernetes-apps' then
                     group {
                       rules: std.map(
                         function(rule)
                           if rule.alert == 'KubeCronJobRunning' then
                             rule {
                               expr: 'time() - kube_cronjob_next_schedule_time{job="kube-state-metrics"} > 604800',
                             }
                           else
                             rule,
                         group.rules
                       ),
                     }
                   else
                     group,
                 super.groups
               ),
             },
           };

local prometheus_ingress = ingress {
  config+:: {
    name: 'prometheus',
    namespace: kp._config.namespace,
    hostname: 'prometheus.charlieegan3.co.uk',
    service: {
      name: kp.prometheus.service.metadata.name,
      port: kp.prometheus.service.spec.ports[0].name,
    },
  },
};

local alertmanager_ingress = ingress {
  config+:: {
    name: 'alertmanager',
    namespace: kp._config.namespace,
    hostname: 'alertmanager.charlieegan3.co.uk',
    service: {
      name: kp.alertmanager.service.metadata.name,
      port: kp.alertmanager.service.spec.ports[0].name,
    },
  },
};

local grafana_ingress = ingress {
  config+:: {
    name: 'grafana',
    namespace: kp._config.namespace,
    hostname: 'grafana.charlieegan3.co.uk',
    service: {
      name: kp.grafana.service.metadata.name,
      port: kp.grafana.service.spec.ports[0].name,
    },
  },
};

local excludedKeys = [
  // prom
  'serviceMonitorKubeControllerManager',
  'serviceMonitorKubeScheduler',
  // grafana
  'dashboardDatasources',
];

// Generate core modules
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) }
// { ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
{
  ['prometheus-' + name]: kp.prometheus[name]
  for name in std.objectFields(kp.prometheus)
  if !std.member(excludedKeys, name)
}
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) if name != 'secret' }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) }
{ ['armExporter-' + name]: kp.armExporter[name] for name in std.objectFields(kp.armExporter) }
{ ['prometheus-ingress-' + name]: prometheus_ingress[name] for name in std.objectFields(prometheus_ingress) }
{ ['alertmanager-ingress-' + name]: alertmanager_ingress[name] for name in std.objectFields(alertmanager_ingress) }
{
  ['grafana-' + name]: kp.grafana[name]
  for name in std.objectFields(kp.grafana)
  if !std.member(excludedKeys, name)
}
{ ['grafana-ingress-' + name]: grafana_ingress[name] for name in std.objectFields(grafana_ingress) }
