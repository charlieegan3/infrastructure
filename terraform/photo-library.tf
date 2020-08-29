resource "google_project" "photo_library" {
  name       = "charlieegan3-photo-library"
  project_id = "charlieegan3-photo-library-001"

  billing_account = var.billing_account
}

resource "google_project_service" "photo_library_storage" {
  project = google_project.photo_library.project_id
  service = "storage-api.googleapis.com"
}

resource "google_service_account" "photo_library" {
  project      = google_project.photo_library.project_id
  account_id   = "runner"
  display_name = "runner refreshing data"
}

resource "google_project_iam_binding" "photo_library_storage_admin" {
  project = google_project.photo_library.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.photo_library.email}",
  ]
}

resource "google_service_account_key" "photo_library" {
  service_account_id = google_service_account.photo_library.name
}

resource "google_storage_bucket" "photo_library" {
  name          = "charlieegan3-photo-library"
  location      = "EU"
  project       = google_project.photo_library.project_id
  storage_class = "STANDARD"

  versioning {
    enabled = false
  }
}
