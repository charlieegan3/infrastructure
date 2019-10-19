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

resource "google_project_services" "project" {
  project = var.project_id

  services = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

resource "google_service_account" "default" {
  account_id   = "cronjob"
  display_name = "cronjob refreshing data"
  project      = var.project_id
}

resource "google_project_iam_binding" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

# allow token creation for cluster workload
resource "google_service_account_iam_binding" "gke_preemptible_killer" {
  service_account_id = google_service_account.default.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:charlieegan3-cluster.svc.id.goog[instagram-archive/instagram-archive-refresh]",
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

