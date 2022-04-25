resource "google_project" "locations" {
  name       = "charlieegan3-locations"
  project_id = "charlieegan3-locations-001"

  billing_account = var.billing_account
}
