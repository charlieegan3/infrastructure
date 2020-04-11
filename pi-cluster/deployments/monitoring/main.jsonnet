local ksm = import 'ksm.jsonnet';
local kp = import 'kube-prometheus.jsonnet';

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

local grafana_config_creator = sc {
  config+:: {
    name: 'grafana-config-creator',
    namespace: namespace,
    vault: {
      role: 'monitoring',
      path: 'secret/monitoring/grafana-datasources',
      key: 'text',
      output: 'datasources.yaml',
    },
    secret_name: 'grafana-datasources',
  },
};

{ ['alertmanager-config-creator-' + name]: alertmanager_config_creator[name] for name in std.objectFields(alertmanager_config_creator) } +
{ ['grafana-config-creator-' + name]: grafana_config_creator[name] for name in std.objectFields(grafana_config_creator) } +
kp + ksm
