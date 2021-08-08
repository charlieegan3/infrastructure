output "photos_cronjob_sa_key" {
  value = google_service_account_key.photos_cronjob.private_key
}
output "vpn_sa_key" {
  value = google_service_account_key.vpn.private_key
}
output "music_uploader_sa_key" {
  value = google_service_account_key.music_bigquery_uploader.private_key
}
output "vault_sa_key" {
  value = google_service_account_key.vault.private_key
}
output "vault_kms_key_id" {
  value = google_kms_crypto_key.vault.self_link
}
