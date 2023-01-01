resource "google_project" "stanley" {
  name       = "charlieegan3-stanley"
  project_id = "charlieegan3-stanley-001"

  billing_account = var.billing_account
}

resource "google_project_service" "stanley_storage_api" {
  project = google_project.stanley.project_id
  service = "storage-api.googleapis.com"
}

resource "google_service_account" "stanley" {
  project      = google_project.stanley.project_id
  account_id   = "stanley"
  display_name = "stanley"
}

resource "google_project_iam_binding" "stanley-storage-admin" {
  project = google_project.stanley.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.stanley.email}",
  ]
}

resource "google_service_account_key" "stanley" {
  service_account_id = google_service_account.stanley.name
}

resource "google_storage_bucket" "stanley" {
  name          = "charlieegan3-stanley"
  project       = google_project.stanley.project_id
  storage_class = "REGIONAL"
  location      = "europe-west2"
}
