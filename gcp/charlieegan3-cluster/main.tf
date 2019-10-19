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

resource "google_project_services" "default" {
  project = var.project_id

  disable_on_destroy = true

  services = [
    "bigquery-json.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddebugger.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "datastore.googleapis.com",
    "deploymentmanager.googleapis.com",
    "drive.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "servicemanagement.googleapis.com",
    "sourcerepo.googleapis.com",
    "sql-component.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
  ]
}

variable "cluster_version" {
  # use gke.2 until the metadata server is fixed
  default = "1.14.6-gke.2"
}
