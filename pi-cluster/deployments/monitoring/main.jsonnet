local kp = import 'kube-prometheus.jsonnet';
local kt = import 'kube-thanos.jsonnet';

local ingress = import 'ingress.jsonnet';
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

local prometheus_ingress = ingress {
  config+:: {
    name: 'prometheus',
    namespace: namespace,
    hostname: 'prometheus.home.charlieegan3.com',
    service: {
      name: kp['prometheus-service'].metadata.name,
      port: kp['prometheus-service'].spec.ports[0].name,
    },
  },
};

local thanos_query_ingress = ingress {
  config+:: {
    name: 'thanos-query',
    namespace: namespace,
    hostname: 'thanos.home.charlieegan3.com',
    service: {
      name: kt['thanos-query-service'].metadata.name,
      port: kt['thanos-query-service'].spec.ports[1].name,
    },
  },
};

local alertmanager_ingress = ingress {
  config+:: {
    name: 'alertmanager',
    namespace: namespace,
    hostname: 'alertmanager.home.charlieegan3.com',
    service: {
      name: kp['alertmanager-service'].metadata.name,
      port: kp['alertmanager-service'].spec.ports[0].name,
    },
  },
};

{ ['thanos-config-creator-' + name]: thanos_config_creator[name] for name in std.objectFields(thanos_config_creator) } +
{ ['alertmanager-config-creator-' + name]: alertmanager_config_creator[name] for name in std.objectFields(alertmanager_config_creator) } +
{ ['prometheus-ingress-' + name]: prometheus_ingress[name] for name in std.objectFields(prometheus_ingress) } +
{ ['thanos-query-ingress-' + name]: thanos_query_ingress[name] for name in std.objectFields(thanos_query_ingress) } +
{ ['alertmanager-ingress-' + name]: alertmanager_ingress[name] for name in std.objectFields(alertmanager_ingress) } +
kp + kt
