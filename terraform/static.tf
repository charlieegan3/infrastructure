# gcp configuration related to hosting static content from various projects

resource "google_project" "static" {
  name       = "charlieegan3-static"
  project_id = "charlieegan3-static-001"

  billing_account = var.billing_account
}

resource "google_project_service" "static_storage_api" {
  project = google_project.static.project_id
  service = "storage-api.googleapis.com"
}

resource "google_storage_bucket" "static" {
  name          = "charlieegan3-static"
  location      = "EU"
  project       = google_project.static.project_id
  storage_class = "STANDARD"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_member" "static_public_access" {
  bucket = google_storage_bucket.static.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_service_account" "static" {
  project      = google_project.static.project_id
  account_id   = "statictask"
  display_name = "statictask"
}

resource "google_project_iam_binding" "static_storage_admin" {
  project = google_project.static.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.static.email}",
  ]
}

resource "google_service_account_key" "static" {
  service_account_id = google_service_account.static.name
}
