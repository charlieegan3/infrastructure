resource "google_project" "locations" {
  name       = "charlieegan3-locations"
  project_id = "charlieegan3-locations-001"

  billing_account = var.billing_account
}

resource "google_bigquery_dataset" "locations" {
  dataset_id    = "locations"
  friendly_name = "locations"
  description   = "locations"
  location      = "EU"
  project       = google_project.locations.project_id
}

