resource "google_storage_bucket" "summary-data-storage" {
  name     = "charlieegan3-music-summary"
  location = "EU"
  project  = var.project_id

  cors {
    origin = [
      "*",
    ]

    method = [
      "*",
    ]
  }
}

resource "google_storage_bucket_iam_binding" "summary-data-storage" {
  bucket = google_storage_bucket.summary-data-storage.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.bigquery_uploader.email}",
  ]
}

resource "google_storage_default_object_acl" "summary-data-storage" {
  bucket = google_storage_bucket.summary-data-storage.name

  role_entity = [
    "READER:allUsers",
  ]
}

resource "google_storage_bucket" "backup-data-storage" {
  name     = "charlieegan3-music-backup"
  location = "EU"
  project  = var.project_id

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age        = 60
      with_state = "LIVE"
    }
  }
}

resource "google_storage_bucket_iam_binding" "backup-data-storage" {
  bucket = google_storage_bucket.backup-data-storage.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.bigquery_uploader.email}",
  ]
}

resource "google_storage_default_object_acl" "backup-data-storage" {
  bucket = google_storage_bucket.backup-data-storage.name

  role_entity = [
    "READER:allUsers",
  ]
}

