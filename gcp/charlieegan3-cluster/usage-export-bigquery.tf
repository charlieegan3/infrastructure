resource "google_bigquery_dataset" "cluster-usage" {
  dataset_id  = "cluster_usage"
  description = "GKE usage export"
  location    = "US"

  project = var.project_id
}

