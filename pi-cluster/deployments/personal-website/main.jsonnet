local p =
  (import 'resources/deployment.jsonnet') +
  (import 'resources/service.jsonnet') +
  (import 'resources/ingress.jsonnet') +
  {
    name: 'personal-website',
    images: {
      web: 'charlieegan3/personal-website:56a124da21803e15d12d5a70a5ca4ad4381b4e46',
    },
    appLabel: 'app.kubernetes.io/name',
  };

{ [p.name + '-' + name]: p.resources[name] for name in std.objectFields(p.resources) }
