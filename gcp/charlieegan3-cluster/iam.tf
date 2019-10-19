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

resource "google_service_account_key" "stackdriver_exporter" {
  service_account_id = google_service_account.stackdriver_exporter.name
}

output "stackdriver_exporter_service_account_key" {
  value = base64decode(google_service_account_key.stackdriver_exporter.private_key)
}

