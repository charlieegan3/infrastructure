resource "google_service_account" "gke_preemptible_killer" {
  account_id = "gke-preemptible-killer"
  project    = var.project_id
}

resource "google_project_iam_member" "gke_preemptible_killer-custom-role" {
  role   = "projects/${var.project_id}/roles/${google_project_iam_custom_role.gke_preemptible_killer.role_id}"
  member = "serviceAccount:${google_service_account.gke_preemptible_killer.email}"

  project = var.project_id

  depends_on = [google_project_iam_custom_role.gke_preemptible_killer]
}

resource "google_project_iam_custom_role" "gke_preemptible_killer" {
  role_id     = "gke_preemptible_killer"
  title       = "GKE Preemptible Killer Role"
  description = "Role to delete nodes before they are killed by google"

  project = var.project_id

  permissions = [
    "compute.instances.delete",
  ]
}

# allow token creation
resource "google_service_account_iam_binding" "gke_preemptible_killer" {
  service_account_id = google_service_account.gke_preemptible_killer.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:charlieegan3-cluster.svc.id.goog[gke-preemptible-killer/gke-preemptible-killer]",
  ]
}

