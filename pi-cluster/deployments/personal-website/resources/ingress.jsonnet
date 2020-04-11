{
  name:: error 'must set project name',

  resources+:: {
    ingress: {
      apiVersion: 'extensions/v1beta1',
      kind: 'Ingress',
      metadata: {
        name: $.name,
        namespace: $.name,
        labels: { app: $.name },
        annotations: {
          'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
          'kubernetes.io/ingress.class': 'nginx',
          'nginx.ingress.kubernetes.io/configuration-snippet': "if ($host = 'www.charlieegan3.com' ) {\n  rewrite ^ https://charlieegan3.com$request_uri permanent;\n}\n",
        },
      },
      spec: {
        tls: [
          {
            hosts: ['charlieegan3.com'],
            secretName: $.name + '-tls',
          },
        ],
        rules: [
          {
            host: 'charlieegan3.com',
            http: {
              paths: [
                {
                  path: '/',
                  backend: {
                    serviceName: $.name,
                    servicePort: 'web',
                  },
                },
              ],
            },
          },
        ],
      },
    },
  },
}
