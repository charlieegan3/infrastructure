resource "google_project" "vpn" {
  name       = "charlieegan3-vpn"
  project_id = "charlieegan3-vpn-001"

  billing_account = var.billing_account
}

resource "google_project_service" "vpn_storage" {
  project = google_project.vpn.project_id
  service = "compute.googleapis.com"
}

resource "google_service_account" "vpn" {
  project      = google_project.vpn.project_id
  account_id   = "deployer"
  display_name = "manages algo instance"
}

resource "google_project_iam_binding" "vpn_compute_admin" {
  project = google_project.vpn.project_id
  role    = "roles/compute.admin"

  members = [
    "serviceAccount:${google_service_account.vpn.email}",
  ]
}

resource "google_project_iam_binding" "vpn_sa_user" {
  project = google_project.vpn.project_id
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.vpn.email}",
  ]
}

resource "google_service_account_key" "vpn" {
  service_account_id = google_service_account.vpn.name
}
