variable "org_id" {
}

variable "billing_account" {
}

variable "project_id" {
  default = "stackr-201915"
}

resource "google_project" "default" {
  name            = "charlieegan3-stackr"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_storage_bucket" "default" {
  name          = "charlieegan3-stackr"
  location      = "EUROPE-WEST1"
  project       = var.project_id
  storage_class = "REGIONAL"
}

resource "google_service_account" "default" {
  account_id   = "stackr"
  display_name = "stackr"
  project      = var.project_id
}

resource "google_project_iam_binding" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

