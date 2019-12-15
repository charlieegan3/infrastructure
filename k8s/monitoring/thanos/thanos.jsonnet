# import kubernetes types
local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local sts = k.apps.v1.statefulSet;
local sts_container = sts.mixin.spec.template.spec.containersType;
local deployment = k.apps.v1.deployment;
local dep_container = deployment.mixin.spec.template.spec.containersType;
local serviceaccount = k.core.v1.serviceAccount;

# generate kube-thanos resources
local kt =
  (import 'kube-thanos/kube-thanos-querier.libsonnet') +
  (import 'kube-thanos/kube-thanos-store.libsonnet') +
  // (import 'kube-thanos/kube-thanos-pvc.libsonnet') + // Uncomment this line to enable PVCs
  // (import 'kube-thanos/kube-thanos-receive.libsonnet') +
  // (import 'kube-thanos/kube-thanos-sidecar.libsonnet') +
  // (import 'kube-thanos/kube-thanos-servicemonitors.libsonnet') +
  {
    thanos+:: {
      // This is just an example image, set what you need
      image:: 'quay.io/thanos/thanos:v0.9.0',
      objectStorageConfig+:: {
        name: 'thanos-objstore-config',
        key: 'thanos.yaml',
      },

      querier+: { },
      store+: { },
    },
  };


# Thanos Store
# * setting smaller resource requests
# * create an annotated service account for workload ID
local store_sts = kt.thanos.store['statefulSet'];
local store_sts_container =
	store_sts.spec.template.spec.containers[0] +
	sts_container.mixin.resources.withRequests({ cpu: '100m', memory: '100Mi' }) +
	sts_container.mixin.resources.withLimits({ cpu: '1', memory: '1Gi' });
local store_sa_name = "thanos-store";
local store_sa = serviceaccount.new(store_sa_name) +
	serviceaccount.mixin.metadata.withAnnotations({
		"iam.gke.io/gcp-service-account": "thanos@charlieegan3-cluster.iam.gserviceaccount.com"
		});

local store = {
	'thanos-store-statefulSet': store_sts +
		sts.mixin.spec.template.spec.withContainers([store_sts_container]) +
		sts.mixin.spec.template.spec.withServiceAccountName(store_sa_name),
	'thanos-store-service': kt.thanos.store['service'],
	'thanos-store-serviceaccount': store_sa,
};

# Thanos Query
# setting smaller resource requests
local querier_deploy = kt.thanos.querier['deployment'];
local querier_deploy_container =
	querier_deploy.spec.template.spec.containers[0] +
	dep_container.mixin.resources.withRequests({ cpu: '100m', memory: '100Mi' }) +
	dep_container.mixin.resources.withLimits({ cpu: '1', memory: '1Gi' });
local querier = {
	'thanos-querier-deployment': querier_deploy +
		deployment.mixin.spec.template.spec.withContainers([querier_deploy_container]),
	'thanos-querier-service': kt.thanos.store['service']
};

# Output the merged configuration of selected components
store + querier
