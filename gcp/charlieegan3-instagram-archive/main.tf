variable "org_id" {
}

variable "billing_account" {
}

variable "project_id" {
  default = "tidal-eon-199618"
}

resource "google_project" "default" {
  name            = "charlieegan3-instagram-archive"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}
resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
}
resource "google_project_service" "monitoring" {
  project = var.project_id
  service = "monitoring.googleapis.com"
}
resource "google_project_service" "oslogin" {
  project = var.project_id
  service = "oslogin.googleapis.com"
}
resource "google_project_service" "stackdriver" {
  project = var.project_id
  service = "stackdriver.googleapis.com"
}
resource "google_project_service" "storage-api" {
  project = var.project_id
  service = "storage-api.googleapis.com"
}

resource "google_service_account" "default" {
  account_id   = "cronjob"
  display_name = "cronjob refreshing data"
  project      = var.project_id
}

resource "google_service_account_key" "cronjob" {
  service_account_id = google_service_account.default.name
}

output "cronjob_sa_key" {
  value = google_service_account_key.cronjob.private_key
}

resource "google_project_iam_binding" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_storage_bucket" "image_backup" {
  name          = "charlieegan3-instagram-archive"
  location      = "EU"
  project       = var.project_id
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }
}

