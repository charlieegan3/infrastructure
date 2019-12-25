local kp = import 'kube-prometheus.jsonnet';
local kt = import 'kube-thanos.jsonnet';

kp + kt
