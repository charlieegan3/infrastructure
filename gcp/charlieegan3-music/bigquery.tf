resource "google_bigquery_dataset" "default" {
  dataset_id    = "music"
  friendly_name = "music"
  description   = "Music Plays"
  location      = "EU"
  project       = var.project_id
}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "plays"
  project    = var.project_id

  schema = file("${path.module}/schema.json")
}

