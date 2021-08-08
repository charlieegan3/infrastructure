resource "google_project" "music" {
  name       = "charlieegan3-music"
  project_id = "charlieegan3-music-001"

  billing_account = var.billing_account
}

resource "google_project_service" "music_bigquery_json" {
  project = google_project.music.project_id
  service = "bigquery.googleapis.com"
}
resource "google_project_service" "music_bigquerydatatransfer" {
  project = google_project.music.project_id
  service = "bigquerydatatransfer.googleapis.com"
}
resource "google_project_service" "music_bigquerystorage" {
  project = google_project.music.project_id
  service = "bigquerystorage.googleapis.com"
}
resource "google_project_service" "music_cloudresourcemanager" {
  project = google_project.music.project_id
  service = "cloudresourcemanager.googleapis.com"
}
resource "google_project_service" "music_iam" {
  project = google_project.music.project_id
  service = "iam.googleapis.com"
}
resource "google_project_service" "music_iamcredentials" {
  project = google_project.music.project_id
  service = "iamcredentials.googleapis.com"
}
resource "google_project_service" "music_pubsub" {
  project = google_project.music.project_id
  service = "pubsub.googleapis.com"
}
resource "google_project_service" "music_storage_api" {
  project = google_project.music.project_id
  service = "storage-api.googleapis.com"
}
resource "google_project_service" "music_youtube" {
  project = google_project.music.project_id
  service = "youtube.googleapis.com"
}

resource "google_bigquery_dataset" "music" {
  dataset_id    = "music"
  friendly_name = "music"
  description   = "Music Plays"
  location      = "EU"
  project       = google_project.music.project_id
}

# resource "google_bigquery_table" "music_plays" {
#  dataset_id = google_bigquery_dataset.music.dataset_id
#  table_id   = "plays"
#  project    = google_project.music.project_id

#  schema = file("music_dataset_schema.json")
# }

resource "google_service_account" "music_bigquery_uploader" {
  account_id   = "bigquery-uploader"
  display_name = "BigQuery Uploader"
  project      = google_project.music.project_id
}

resource "google_project_iam_binding" "music_upload" {
  project = google_project.music.project_id
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.music_bigquery_uploader.email}",
  ]
}

resource "google_project_iam_binding" "music_query" {
  project = google_project.music.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.music_bigquery_uploader.email}",
  ]
}

resource "google_service_account_key" "music_bigquery_uploader" {
  service_account_id = google_service_account.music_bigquery_uploader.name
}

resource "google_storage_bucket" "music_summary_data_storage" {
  name     = "charlieegan3-music-data-summary"
  location = "EU"
  project  = google_project.music.project_id

  cors {
    origin = [
      "*",
    ]

    method = [
      "*",
    ]
  }
}

resource "google_storage_bucket_iam_binding" "music_summary_data_storage" {
  bucket = google_storage_bucket.music_summary_data_storage.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.music_bigquery_uploader.email}",
  ]
}

resource "google_storage_default_object_acl" "music_summary_data_storage" {
  bucket = google_storage_bucket.music_summary_data_storage.name

  role_entity = [
    "READER:allUsers",
  ]
}

resource "google_storage_bucket" "music_backup_data_storage" {
  name     = "charlieegan3-music-data-backup"
  location = "EU"
  project  = google_project.music.project_id

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

resource "google_storage_bucket_iam_binding" "music_backup_data_storage" {
  bucket = google_storage_bucket.music_backup_data_storage.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.music_bigquery_uploader.email}",
  ]
}

resource "google_storage_default_object_acl" "music_backup_data_storage" {
  bucket = google_storage_bucket.music_backup_data_storage.name

  role_entity = [
    "READER:allUsers",
  ]
}
