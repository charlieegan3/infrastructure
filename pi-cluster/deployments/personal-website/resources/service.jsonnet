local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';

local service = k.core.v1.service;

{
  name:: error 'must set project name',
  appLabel:: error 'must set appLabel',

  resources+:: {
    service:
      service.new(
        $.name,
        { [$.appLabel]: $.name },
        [{
          name: 'web',
          port: 80,
          targetPort: $.resources.deployment.spec.template.spec.containers[0].ports[0].containerPort,
          protocol: 'TCP',
        }]
      ) +
      service.mixin.metadata.withNamespace($.name) +
      service.mixin.metadata.withLabels({ [$.appLabel]: $.name }),
  },
}
