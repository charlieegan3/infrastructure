local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';

local deployment = k.apps.v1.deployment;
local container = deployment.mixin.spec.template.spec.containersType;


{
  name:: error 'must set project name',
  appLabel:: error 'must set appLabel',

  resources+:: {
    deployment:
      local c =
        container.new($.name, $.images.web) +
        container.mixin.resources.withRequests({ cpu: '50m', memory: '100Mi' }) +
        container.mixin.resources.withLimits({ cpu: '100m', memory: '200Mi' }) +
        container.withPorts([
          { containerPort: 80 },
        ]);

      deployment.new($.name, 2, c, {}) +
      deployment.mixin.metadata.withNamespace($.name) +
      deployment.mixin.metadata.withLabels({ [$.appLabel]: $.name }) +
      deployment.mixin.spec.selector.withMatchLabels($.resources.deployment.metadata.labels) +
      deployment.mixin.spec.template.metadata.withLabels($.resources.deployment.metadata.labels),
  },
}
