resource "google_project" "photos" {
  name       = "charlieegan3-photos"
  project_id = "charlieegan3-photos"

  # billing_account = var.billing_account
}

resource "google_project_service" "photos_storage_api" {
  project = google_project.photos.project_id
  service = "storage-api.googleapis.com"
}

resource "google_service_account" "photos_cronjob" {
  project      = google_project.photos.project_id
  account_id   = "cronjob"
  display_name = "cronjob refreshing data"
}

resource "google_project_iam_binding" "storage_admin" {
  project = google_project.photos.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.photos_cronjob.email}",
  ]
}

resource "google_service_account_key" "photos_cronjob" {
  service_account_id = google_service_account.photos_cronjob.name
}

resource "google_storage_bucket" "photos" {
  name          = "charlieegan3-photos"
  location      = "EU"
  project       = google_project.photos.project_id
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }
}
