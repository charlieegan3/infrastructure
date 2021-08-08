resource "google_storage_bucket" "photo_library" {
  name          = "charlieegan3-photo-library"
  location      = "EU"
  project       = "charlieegan3-photo-library-001"
  storage_class = "STANDARD"
  force_destroy = true

  versioning {
    enabled = false
  }
}
