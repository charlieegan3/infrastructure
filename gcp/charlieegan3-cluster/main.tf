variable "org_id" {
}

variable "billing_account" {
}

variable "project_id" {
  default = "charlieegan3-cluster"
}

variable "cluster_zone" {
  default = "us-east1-b"
}

resource "google_project" "default" {
  name            = var.project_id
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_project_service" "bq" {
  project = var.project_id
  service = "bigquery-json.googleapis.com"
}
resource "google_project_service" "bq-storage" {
  project = var.project_id
  service = "bigquerystorage.googleapis.com"
}
resource "google_project_service" "cloudapis" {
  project = var.project_id
  service = "cloudapis.googleapis.com"
}
resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}
resource "google_project_service" "clouddebugger" {
  project = var.project_id
  service = "clouddebugger.googleapis.com"
}
resource "google_project_service" "bq-json" {
  project = var.project_id
  service = "bigquery-json.googleapis.com"
}
resource "google_project_service" "cloudkms" {
  project = var.project_id
  service = "cloudkms.googleapis.com"
}
resource "google_project_service" "cloudtrace" {
  project = var.project_id
  service = "cloudtrace.googleapis.com"
}
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}
resource "google_project_service" "container-registry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
}
resource "google_project_service" "datastore" {
  project = var.project_id
  service = "datastore.googleapis.com"
}
resource "google_project_service" "deploymentmanager" {
  project = var.project_id
  service = "deploymentmanager.googleapis.com"
}
resource "google_project_service" "drive" {
  project = var.project_id
  service = "drive.googleapis.com"
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
resource "google_project_service" "replicapool" {
  project = var.project_id
  service = "replicapool.googleapis.com"
}
resource "google_project_service" "replicapoolupdater" {
  project = var.project_id
  service = "replicapoolupdater.googleapis.com"
}
resource "google_project_service" "resource-views" {
  project = var.project_id
  service = "resourceviews.googleapis.com"
}
resource "google_project_service" "service-management" {
  project = var.project_id
  service = "servicemanagement.googleapis.com"
}
resource "google_project_service" "serviceusage" {
  project = var.project_id
  service = "serviceusage.googleapis.com"
}
resource "google_project_service" "sourcerepo" {
  project = var.project_id
  service = "sourcerepo.googleapis.com"
}
resource "google_project_service" "sqlcomponent" {
  project = var.project_id
  service = "sql-component.googleapis.com"
}
resource "google_project_service" "stackdriver" {
  project = var.project_id
  service = "stackdriver.googleapis.com"
}
resource "google_project_service" "storage-api" {
  project = var.project_id
  service = "storage-api.googleapis.com"
}
resource "google_project_service" "storage-component" {
  project = var.project_id
  service = "storage-component.googleapis.com"
}

variable "cluster_version" {
  default = "1.14"
}
