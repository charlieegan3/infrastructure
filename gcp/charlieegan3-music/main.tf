variable "org_id" {
}

variable "billing_account" {
}

variable "project_id" {
  default = "charlieegan3-music-1"
}

resource "google_project" "charlieegan3-music" {
  name            = "charlieegan3-music"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_project_services" "project" {
  project = var.project_id

  services = [
    "bigquery-json.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "youtube.googleapis.com",
  ]
}

