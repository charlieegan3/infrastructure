local k = import 'ksonnet-lib/ksonnet.beta.4/k.libsonnet';

local serviceAccount = k.core.v1.serviceAccount;
local role = k.rbac.v1.role;
local roleBinding = k.rbac.v1.roleBinding;

{
  name:: error 'must set project name',

  resources+:: {
    serviceAccount:
      serviceAccount.new('config-map-creator') +
      serviceAccount.mixin.metadata.withNamespace($.name),

    role:
      role.new() +
      role.mixin.metadata.withName('config-map-create') +
      role.mixin.metadata.withNamespace($.name) +
      role.withRules(
        {
          apiGroups: [''],
          resources: ['configmaps'],
          verbs: std.split('create update get list patch', ' '),
        }
      ),

    roleBinding:
      roleBinding.new() +
      roleBinding.mixin.metadata.withName($.resources.role.metadata.name) +
      roleBinding.mixin.metadata.withNamespace($.name) +
      roleBinding.withSubjects([
        {
          kind: 'ServiceAccount',
          name: $.resources.serviceAccount.metadata.name,
          namespace: $.name,
        },
      ]) +
      roleBinding.mixin.roleRef.mixinInstance({
        kind: 'Role',
        name: $.resources.role.metadata.name,
        apiGroup: 'rbac.authorization.k8s.io',
      }),
  },
}
