resource "google_service_account" "stackdriver_exporter" {
  account_id   = "stackdriver-exporter"
  display_name = "Stackdriver Prometheus Exporter"
  project      = var.project_id
}

resource "google_project_iam_binding" "upload" {
  project = var.project_id
  role    = "roles/monitoring.viewer"

  members = [
    "serviceAccount:${google_service_account.stackdriver_exporter.email}",
  ]
}

resource "google_service_account_iam_binding" "stackdriver_exporter" {
  service_account_id = google_service_account.stackdriver_exporter.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:charlieegan3-cluster.svc.id.goog[monitoring/stackdriver-exporter]"]
}

resource "google_service_account" "bigquery-user-readonly" {
  account_id   = "bigquery-user-readonly"
  display_name = "BigQuery User (readonly)"
  project      = var.project_id
}

resource "google_project_iam_binding" "data-viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"

  members = [
    "serviceAccount:${google_service_account.bigquery-user-readonly.email}",
  ]
}

resource "google_project_iam_binding" "job-user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.bigquery-user-readonly.email}",
  ]
}

resource "google_service_account_iam_binding" "bigquery-user" {
  service_account_id = google_service_account.bigquery-user-readonly.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:charlieegan3-cluster.svc.id.goog[monitoring/gf-grafana]"]
}

resource "google_storage_bucket" "thanos-storage" {
  name     = "charlieegan3-cluster-thanos"
  location = "US"
  project  = var.project_id
}

resource "google_storage_bucket_iam_binding" "thanos-binding" {
  bucket = "${google_storage_bucket.thanos-storage.name}"
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.thanos.email}",
  ]
}

resource "google_service_account" "thanos" {
  account_id = "thanos"
  project    = var.project_id
}

resource "google_service_account_iam_binding" "thanos-pod" {
  service_account_id = google_service_account.thanos.name
  role               = "roles/iam.serviceAccountTokenCreator"

  # thanos runs as a sidecar in the prometheus pod
  members = ["serviceAccount:charlieegan3-cluster.svc.id.goog[monitoring/po-promop-prometheus]"]
}
