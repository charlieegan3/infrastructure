resource "google_service_account" "bigquery_uploader" {
  account_id   = "bigquery-uploader"
  display_name = "BigQuery Uploader"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "bigquery_uploader" {
  service_account_id = google_service_account.bigquery_uploader.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:charlieegan3-cluster.svc.id.goog[music/music-sync]"]
}

resource "google_project_iam_binding" "upload" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.bigquery_uploader.email}",
  ]
}

resource "google_project_iam_binding" "query" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.bigquery_uploader.email}",
  ]
}

resource "google_service_account_key" "bigquery_uploader" {
  service_account_id = google_service_account.bigquery_uploader.name
}

output "bigquery_uploader_sa_key" {
  value = google_service_account_key.bigquery_uploader.private_key
}
