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

resource "google_project_service" "bigquery-json" {
  project = var.project_id
  service = "bigquery-json.googleapis.com"
}
resource "google_project_service" "bigquerydatatransfer" {
  project = var.project_id
  service = "bigquerydatatransfer.googleapis.com"
}
resource "google_project_service" "bigquerystorage" {
  project = var.project_id
  service = "bigquerystorage.googleapis.com"
}
resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}
resource "google_project_service" "containerregistry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
}
resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}
resource "google_project_service" "iamcredentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
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
resource "google_project_service" "pubsub" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}
resource "google_project_service" "stackdriver" {
  project = var.project_id
  service = "stackdriver.googleapis.com"
}
resource "google_project_service" "storage-api" {
  project = var.project_id
  service = "storage-api.googleapis.com"
}
resource "google_project_service" "youtube" {
  project = var.project_id
  service = "youtube.googleapis.com"
}

