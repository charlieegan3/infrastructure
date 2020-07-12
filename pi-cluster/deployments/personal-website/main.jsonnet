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
      json: 'charlieegan3/json-charlieegan3:arm-8338a7932a5d27e7340fc2e474cef123',
    },
    appLabel: 'app.kubernetes.io/name',
  };

{ [p.name + '-' + name]: p.resources[name] for name in std.objectFields(p.resources) }
