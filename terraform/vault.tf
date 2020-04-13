resource "google_project" "vault" {
  name       = "charlieegan3-vault"
  project_id = "charlieegan3-vault-001"

  billing_account = var.billing_account
}

resource "google_project_service" "vault_cloudkms" {
  project = google_project.vault.project_id
  service = "cloudkms.googleapis.com"
}

resource "google_service_account" "vault" {
  project      = google_project.vault.project_id
  account_id   = "vault-server"
  display_name = "Pi Cluster Vault"
}

resource "google_service_account_key" "vault" {
  service_account_id = google_service_account.vault.name
}

resource "google_kms_key_ring" "vault" {
  name     = "vault"
  location = "global"
  project  = google_project.vault.project_id

  depends_on = [
    # the API must be enabled
    google_project_service.vault_cloudkms
  ]
}

resource "google_kms_crypto_key" "vault" {
  name            = "vault"
  key_ring        = google_kms_key_ring.vault.self_link
  rotation_period = "15780000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_binding" "vault" {
  crypto_key_id = google_kms_crypto_key.vault.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.vault.email}",
  ]
}
