resource "google_service_account" "kubeip" {
  account_id = "kubeip"
  project    = var.project_id
}

resource "google_project_iam_member" "kubeip-service-account-custom-role" {
  role   = "projects/${var.project_id}/roles/${google_project_iam_custom_role.kubeip-role.role_id}"
  member = "serviceAccount:${google_service_account.kubeip.email}"

  project = var.project_id

  depends_on = [google_project_iam_custom_role.kubeip-role]
}

resource "google_project_iam_custom_role" "kubeip-role" {
  role_id     = "kubeipRole"
  title       = "kubeip Role"
  description = "Role with permissions for kubeip to create service accounts https://www.kubeipproject.io/docs/secrets/gcp/index.html#required-permissions"

  project = var.project_id

  permissions = [
    "compute.addresses.list",
    "compute.instances.addAccessConfig",
    "compute.instances.deleteAccessConfig",
    "compute.instances.get",
    "compute.instances.list",
    "compute.projects.get",
    "container.clusters.get",
    "container.clusters.list",
    "resourcemanager.projects.get",
    "compute.subnetworks.useExternalIp",
    "compute.addresses.use",
  ]
}

# allow token creation
resource "google_service_account_iam_binding" "workload_kubeip_token_create" {
  service_account_id = google_service_account.kubeip.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:charlieegan3-cluster.svc.id.goog[kube-system/kubeip-sa]",
  ]
}

