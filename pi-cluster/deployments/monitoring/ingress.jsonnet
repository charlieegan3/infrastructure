{

  local ingress = self,

  config:: {
    name: error 'must provide name',
    namespace: error 'must provide namespace',
    hostname: error 'must set hostname',
    service: {
      port: error 'must set service port',
      name: error 'must set service name',
    },
  },

  ingress: {
    apiVersion: 'extensions/v1beta1',
    kind: 'Ingress',
    metadata: {
      name: ingress.config.name,
      namespace: ingress.config.namespace,
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
        'kubernetes.io/ingress.class': 'nginx',
        'nginx.ingress.kubernetes.io/auth-url': 'https://auth.charlieegan3.co.uk/oauth2/auth',
        'nginx.ingress.kubernetes.io/auth-signin': 'https://auth.charlieegan3.co.uk/oauth2/start?rd=https://' + ingress.config.hostname,
      },
    },
    spec: {
      tls: [
        {
          hosts: [ingress.config.hostname],
          secretName: ingress.config.name + '-tls',
        },
      ],
      rules: [
        {
          host: ingress.config.hostname,
          http: {
            paths: [
              {
                path: '/',
                backend: {
                  serviceName: ingress.config.service.name,
                  servicePort: ingress.config.service.port,
                },
              },
            ],
          },
        },
      ],
    },
  },
}
