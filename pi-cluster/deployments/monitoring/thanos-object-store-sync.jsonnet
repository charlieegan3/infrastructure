local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';

{
  cronjob: k.batch.v1beta1.cronJob.new() +
           {
             metadata: {
               name: 'thanos-object-store-sync',
               namespace: 'monitoring',
             },
             spec: {
               concurrencyPolicy: 'Forbid',
               schedule: '* * * * *',
               successfulJobsHistoryLimit: 1,
               failedJobsHistoryLimit: 1,
               jobTemplate: {
                 metadata: {
                   labels: {
                     cronjob: 'thanos-object-store-creator',
                   },
                 },
                 spec: {
                   template: {
                     metadata: {
                       annotations: {
                         'vault.hashicorp.com/agent-inject': 'true',
                         'vault.hashicorp.com/role': 'monitoring',
                         'vault.hashicorp.com/agent-pre-populate-only': 'true',
                         'vault.hashicorp.com/agent-inject-secret-thanos.yaml':
                           'secret/monitoring/thanos-config',
                         'vault.hashicorp.com/agent-inject-template-thanos.yaml': |||
                           {{- with secret "secret/monitoring/thanos-config" -}}
                           {{- .Data.text -}}
                           {{- end -}}
                         |||,
                       },
                     },
                     spec: {
                       restartPolicy: 'Never',
                       serviceAccount: 'thanos-obj-store-creator',
                       containers: [
                         {
                           name: 'create-config-map',
                           image: 'gcr.io/google_containers/hyperkube-arm:v1.15.5',
                           command: [
                             '/bin/sh',
                             '-c',
                             |||
                               kubectl create secret generic thanos-objstore-config \
                               --from-file=/vault/secrets/thanos.yaml \
                               -n monitoring \
                               -o yaml \
                               --dry-run > secret.yaml && \
                               kubectl apply -f secret.yaml
                             |||,
                           ],
                         },
                       ],
                     },
                   },
                 },
               },
             },
           },
  serviceaccount: k.core.v1.serviceAccount.new() +
                  {
                    metadata: {
                      name: 'thanos-obj-store-creator',
                      namespace: 'monitoring',
                    },
                  },
  role: k.rbac.v1.role.new() +
        {
          metadata: {
            name: 'secrets-creator',
            namespace: 'monitoring',
          },
          rules: [
            {
              apiGroups: [
                '',
              ],
              resources: [
                'secrets',
              ],
              verbs: [
                'create',
                'update',
                'get',
                'list',
                'patch',
              ],
            },
          ],
        },
  binding: k.rbac.v1.roleBinding.new() +
           {
             metadata: {
               name: 'secrets-creator-thanos',
               namespace: 'monitoring',
             },
             subjects: [
               {
                 kind: 'ServiceAccount',
                 name: 'thanos-obj-store-creator',
                 namespace: 'monitoring',
               },
             ],
             roleRef: {
               kind: 'Role',
               name: 'secrets-creator',
               apiGroup: 'rbac.authorization.k8s.io',
             },
           },
}
