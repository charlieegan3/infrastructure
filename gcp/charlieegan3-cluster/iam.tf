# single account for all monitoring components
resource "google_service_account" "monitoring" {
  account_id   = "monitoring"
  display_name = "Cluster Monitoring Components"
  project      = var.project_id
}

resource "google_service_account_key" "monitoring" {
  service_account_id = google_service_account.monitoring.name
}

output "monitoring_sa_key" {
  value = google_service_account_key.monitoring.private_key
}

# for stackdriver exporter
resource "google_project_iam_binding" "monitoring-viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}

# for grafana bq datasource
resource "google_project_iam_binding" "bq-data-viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}
resource "google_project_iam_binding" "bq-job-user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}

# for thanos store
resource "google_storage_bucket" "thanos-storage" {
  name     = "charlieegan3-cluster-thanos"
  location = "US"
  project  = var.project_id
}
# pi cluster thanos
resource "google_storage_bucket" "thanos-store" {
  name     = "charlieegan3-cluster-thanos-store"
  location = "EU"
  project  = var.project_id
}

resource "google_storage_bucket_iam_binding" "thanos-object-admin" {
  bucket = "${google_storage_bucket.thanos-storage.name}"
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "thanos-store-object-admin" {
  bucket = "${google_storage_bucket.thanos-store.name}"
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}
