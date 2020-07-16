local p =
  (import 'resources/deployment.jsonnet') +
  (import 'resources/service.jsonnet') +
  (import 'resources/rbac.jsonnet') +
  (import 'resources/cronjob.jsonnet') +
  (import 'resources/ingress.jsonnet') +
  {
    name: 'personal-website',
    images: {
      web: 'charlieegan3/personal-website:0047d51edfa078c4ca5b3e4b82b52a5c61aaca9a',
      json: 'charlieegan3/json-charlieegan3:arm-d10d67cb0b9c5b6db8543461dcd978b5',
    },
    appLabel: 'app.kubernetes.io/name',
  };

{ [p.name + '-' + name]: p.resources[name] for name in std.objectFields(p.resources) }
