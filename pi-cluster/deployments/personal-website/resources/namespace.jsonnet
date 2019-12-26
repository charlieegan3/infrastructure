local k = import 'ksonnet-lib/ksonnet.beta.4/k.libsonnet';

{
  name:: error 'must set project name',

  resources+:: {
    '0namespace': k.core.v1.namespace.new($.name),
  },
}
