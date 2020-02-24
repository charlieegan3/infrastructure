local ksm = import 'ksm.jsonnet';
local kp = import 'kube-prometheus.jsonnet';
local kt = import 'kube-thanos.jsonnet';

local sc = import 'secret-creator.jsonnet';

local namespace = 'monitoring';

local alertmanager_config_creator = sc {
  config+:: {
    name: 'alertmanager-config-creator',
    namespace: namespace,
    vault: {
      role: 'monitoring',
      path: 'secret/monitoring/alertmanager-config',
      key: 'text',
      output: 'alertmanager.yaml',
    },
    secret_name: 'alertmanager-main',
  },
};

local thanos_config_creator = sc {
  config+:: {
    name: 'thanos-config-creator',
    namespace: namespace,
    vault: {
      role: 'monitoring',
      path: 'secret/monitoring/thanos-config',
      key: 'text',
      output: 'thanos.yaml',
    },
    secret_name: 'thanos-objstore-config',
  },
};

{ ['thanos-config-creator-' + name]: thanos_config_creator[name] for name in std.objectFields(thanos_config_creator) } +
{ ['alertmanager-config-creator-' + name]: alertmanager_config_creator[name] for name in std.objectFields(alertmanager_config_creator) } +
kp + kt + ksm
