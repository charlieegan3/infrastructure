output "inlets_sa_key" {
  value = google_service_account_key.inlets.private_key
}

variable "org_id" {
}

variable "billing_account" {
}

variable "project_id" {
  default = "charlieegan3-inlets"
}

variable "region" {
  default = "us-east1"
}

resource "google_project" "default" {
  name            = var.project_id
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_service_account" "inlets" {
  account_id = "inlets-operator"
  project    = var.project_id
}

resource "google_service_account_key" "inlets" {
  service_account_id = google_service_account.inlets.name
}

resource "google_project_iam_binding" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"

  members = [
    "serviceAccount:${google_service_account.inlets.email}",
  ]
}

resource "google_compute_address" "inlets" {
  project = var.project_id
  address = "35.190.146.159"
  name    = "inlets"
  region  = var.region
}
