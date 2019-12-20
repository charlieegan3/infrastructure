resource "google_storage_bucket" "vault-storage" {
  name     = "charlieegan3-cluster-vault-storage"
  location = "US"
  project  = var.project_id
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = "${google_storage_bucket.vault-storage.name}"
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.vault.email}",
  ]
}

resource "google_service_account" "vault" {
  account_id = "vault-server"
  project    = var.project_id
}

resource "google_kms_key_ring" "vault" {
  name     = "vault-key-ring"
  location = "global"
  project  = var.project_id
}

resource "google_kms_crypto_key" "vault" {
  name            = "vault-server"
  key_ring        = google_kms_key_ring.vault.self_link
  rotation_period = "15780000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_binding" "vault" {
  crypto_key_id = "${var.project_id}/global/${google_kms_key_ring.vault.name}/${google_kms_crypto_key.vault.name}"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.vault.email}",
  ]
}

resource "google_service_account_key" "vault" {
  service_account_id = google_service_account.vault.name
}

output "vault_kms_key_id" {
  value = google_kms_crypto_key.vault.self_link
}

output "vault_sa_key" {
  value = google_service_account_key.vault.private_key
}
