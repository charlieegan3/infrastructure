local k = import 'ksonnet-lib/ksonnet.beta.4/k.libsonnet';

local cronJob = k.batch.v1beta1.cronJob;
local container = cronJob.mixin.spec.jobTemplate.spec.template.spec.containersType;

{
  name:: error 'must set project name',

  resources+:: {
    cronjob:
      local containerReloader =
        container.new('json-reloader', $.images.json) +
        container.withCommand([
          '/statusUpdater',
          '--refresh=true',
          '--output=/shared/status.json',
        ]) +
        container.withEnv([{
          name: 'ENV_PATH',
          value: '/vault/secrets/env',
        }]) +
        container.mixin.resources.withRequests({ cpu: '10m', memory: '10Mi' }) +
        container.mixin.resources.withLimits({ cpu: '200m', memory: '50Mi' }) +
        container.withVolumeMounts(
          [{ name: 'shared', mountPath: '/shared' }]
        );

      local containerConfigMapCreator =
        container.new('create-config-map', 'gcr.io/google_containers/hyperkube:v1.15.5') +
        container.withCommand([
          '/bin/sh',
          '-c',
          |||
            while [ ! -f /shared/status.json ]
            do
              echo "status not found, waiting"
              sleep 1
            done
            kubectl create configmap status-json -n personal-website --from-file=/shared/status.json -o yaml --dry-run > configmap.yaml
            kubectl apply -f configmap.yaml
          |||,
        ]) +
        container.mixin.resources.withRequests({ cpu: '10m', memory: '10Mi' }) +
        container.mixin.resources.withLimits({ cpu: '200m', memory: '50Mi' }) +
        container.withVolumeMounts(
          [{ name: 'shared', mountPath: '/shared' }]
        );


      cronJob.new() +
      cronJob.mixin.metadata.withName('status-json-refresh') +
      cronJob.mixin.metadata.withNamespace($.name) +
      cronJob.mixin.spec.withSchedule('*/10 * * * *') +
      cronJob.mixin.spec.withConcurrencyPolicy('Forbid') +
      cronJob.mixin.spec.withSuccessfulJobsHistoryLimit(1) +
      cronJob.mixin.spec.withStartingDeadlineSeconds(30) +
      cronJob.mixin.spec.withFailedJobsHistoryLimit(1) +
      cronJob.mixin.spec.jobTemplate.spec.template.spec.withRestartPolicy('OnFailure') +

      cronJob.mixin.spec.jobTemplate.spec.template.metadata.withAnnotations(
        {
          'vault.hashicorp.com/agent-inject': 'true',
          'vault.hashicorp.com/role': $.name,
          'vault.hashicorp.com/agent-pre-populate-only': 'true',
          'vault.hashicorp.com/agent-inject-secret-env': 'secret/personal-website/main',
          'vault.hashicorp.com/agent-inject-template-env': |||
            {{- with secret "secret/personal-website/main" -}}
            {{- .Data.text -}}
            {{- end -}}
          |||,
        }
      ) +

      cronJob.mixin.spec.jobTemplate.spec.template.spec.withVolumes([
        { name: 'shared', emptyDir: {} },
      ]) +
      cronJob.mixin.spec.jobTemplate.spec.template.spec.withServiceAccountName(
        $.resources.serviceAccount.metadata.name
      ) +
      cronJob.mixin.spec.jobTemplate.spec.template.spec.withContainers([
        containerReloader,
        containerConfigMapCreator,
      ]),
  },
}
