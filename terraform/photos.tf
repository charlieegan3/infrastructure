resource "google_project" "photos" {
  name       = "charlieegan3-photos"
  project_id = "charlieegan3-photos-001"

  billing_account = var.billing_account
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

resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.photos.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

// items relating to the CMS application

resource "google_storage_bucket" "cms" {
  name          = "charlieegan3-photos-cms"
  location      = "EU"
  project       = google_project.photos.project_id
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "cms_database_backups" {
  name          = "charlieegan3-photos-cms-database-backups"
  location      = "EU"
  project       = google_project.photos.project_id

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_member" "public_access_cms" {
  bucket = google_storage_bucket.cms.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_service_account" "photos_cms" {
  project      = google_project.photos.project_id
  account_id   = "photos-cms"
  display_name = "CMS Application"
}

resource "google_storage_bucket_iam_member" "cms_admin" {
  bucket = google_storage_bucket.cms.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.photos_cms.email}"
}

resource "google_service_account" "photos_cms_gh_actions" {
  project      = google_project.photos.project_id
  account_id   = "github-actions"
  display_name = "GitHub Actions"
}

resource "google_storage_bucket_iam_member" "gh_actions_database_backups" {
  bucket = google_storage_bucket.cms_database_backups.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.photos_cms_gh_actions.email}"
}

// bigquery points settings

resource "google_project_service" "project" {
  project = google_project.photos.project_id
  service = "bigquery.googleapis.com"
  disable_dependent_services = false
}

resource "google_bigquery_dataset" "location" {
  project = google_project.photos.project_id

  dataset_id    = "location"
  friendly_name = "location"
  location      = "EU"

  access {
    role          = "OWNER"
    user_by_email = google_service_account.photos_cms.email
  }
}

resource "google_bigquery_table" "photos_points" {
  dataset_id = google_bigquery_dataset.location.dataset_id
  table_id   = "points"
  project    = google_project.photos.project_id

  schema = file("points_table_schema.json")
}

resource "google_project_iam_binding" "photos_bq_upload" {
  project = google_project.photos.project_id
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.photos_cms.email}",
  ]
}

resource "google_project_iam_binding" "photos_bq_jobs" {
  project = google_project.photos.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.photos_cms.email}",
  ]
}

// service account keys for outputs
resource "google_service_account_key" "photos_cms" {
  service_account_id = google_service_account.photos_cms.name
}

resource "google_service_account_key" "photos_cms_gh_actions" {
  service_account_id = google_service_account.photos_cms_gh_actions.name
}
