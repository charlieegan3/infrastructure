local utils = import 'utils.libsonnet';
local vars = import 'vars.jsonnet';

local kp = (import 'kube-prometheus/kube-prometheus.libsonnet')
           + (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet')
           + (import 'kube-prometheus/kube-prometheus-kops-coredns.libsonnet')
           + (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet')
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

// Generate core modules
{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) }
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) }
// { ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) }
// { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) }
// { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) }
// TODO enable ingress
// { ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
{ ['armExporter-' + name]: kp.armExporter[name] for name in std.objectFields(kp.armExporter) }
