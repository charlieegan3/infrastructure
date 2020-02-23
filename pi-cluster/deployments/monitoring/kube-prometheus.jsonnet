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
           + (import 'image_sources_versions.jsonnet');

local excludedKeys = [
  'serviceMonitorKubeControllerManager',
  'serviceMonitorKubeScheduler',
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
// { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) }
// TODO enable ingress
// { ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
{ ['armExporter-' + name]: kp.armExporter[name] for name in std.objectFields(kp.armExporter) }
