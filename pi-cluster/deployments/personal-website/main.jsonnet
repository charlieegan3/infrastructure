local p =
  (import 'resources/deployment.jsonnet') +
  (import 'resources/service.jsonnet') +
  (import 'resources/rbac.jsonnet') +
  (import 'resources/cronjob.jsonnet') +
  {
    name: 'personal-website',
    images: {
      web: 'charlieegan3/personal-website:arm-1a5375bf552d8ea372ea02fe245646ef',
      json: 'charlieegan3/json-charlieegan3:arm-8ff0c09dd41f236461e7bcf6ddc5874d',
    },
    appLabel: 'app.kubernetes.io/name',
  };

{ [p.name + '-' + name]: p.resources[name] for name in std.objectFields(p.resources) }
