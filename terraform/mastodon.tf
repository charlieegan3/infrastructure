resource "google_project" "mastodon" {
  name       = "charlieegan3-mastodon"
  project_id = "charlieegan3-mastodon-001"

  billing_account = var.billing_account
}

resource "google_project_service" "mastodon_storage_api" {
  project = google_project.mastodon.project_id
  service = "storage-api.googleapis.com"
}

resource "google_service_account" "mastodon" {
  project      = google_project.mastodon.project_id
  account_id   = "mastodon"
  display_name = "mastodon"
}

resource "google_project_iam_binding" "mastodon-storage-admin" {
  project = google_project.mastodon.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.mastodon.email}",
  ]
}

resource "google_service_account_key" "mastodon" {
  service_account_id = google_service_account.mastodon.name
}

resource "google_storage_bucket" "mastodon" {
  name          = "charlieegan3-mastodon"
  project       = google_project.mastodon.project_id
  storage_class = "REGIONAL"
  location      = "europe-west2"
}
