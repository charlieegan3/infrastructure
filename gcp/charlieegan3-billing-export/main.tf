variable "org_id" {
}

variable "billing_account" {
}

variable "project_id" {
  default = "charlieegan3-billing-export"
}

resource "google_project" "default" {
  name            = var.project_id
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_project_services" "project" {
  project = var.project_id

  services = [
    "bigquery-json.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

resource "google_bigquery_dataset" "billing_export" {
  dataset_id = "charlieegan3_billing_export"

  lifecycle {
    ignore_changes = [
      access, # this needed to stop plan trashing on updating the access
    ]
  }

  access {
    role          = "roles/bigquery.dataViewer"
    user_by_email = "bigquery-user-readonly@charlieegan3-cluster.iam.gserviceaccount.com"
  }
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "OWNER"
    user_by_email = "billing-export-bigquery@system.gserviceaccount.com"
  }
  access {
    role          = "OWNER"
    user_by_email = "c@egan.co"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}

resource "google_service_account" "cloud-billing-exporter" {
  account_id   = "cloud-billing-exporter"
  display_name = "cloud-billing-exporter"
  project      = var.project_id
}

resource "google_storage_bucket_iam_binding" "billing-export-data-access" {
  bucket = "charlieegan3-billing-export"
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.cloud-billing-exporter.email}",
  ]
}

resource "google_service_account_iam_binding" "cloud-billing-exporter-workload" {
  service_account_id = google_service_account.cloud-billing-exporter.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:charlieegan3-cluster.svc.id.goog[monitoring/cloud-billing-exporter]"]
}
