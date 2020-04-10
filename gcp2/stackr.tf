resource "google_project" "stackr" {
  name       = "charlieegan3-stackr"
  project_id = "charlieegan3-stackr-001"

  billing_account = var.billing_account
}

resource "google_storage_bucket" "stackr" {
  name          = "charlieegan3-stackr-images"
  location      = "EUROPE-WEST1"
  project       = google_project.stackr.project_id
  storage_class = "REGIONAL"
}

resource "google_service_account" "stackr" {
  account_id   = "stackr"
  display_name = "stackr"
  project      = google_project.stackr.project_id
}

resource "google_project_iam_binding" "stackr_storage_admin" {
  project = google_project.stackr.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.stackr.email}",
  ]
}
