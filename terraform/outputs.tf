output "photos_cronjob_sa_key" {
  value = google_service_account_key.photos_cronjob.private_key
}
output "music_uploader_sa_key" {
  value = google_service_account_key.music_bigquery_uploader.private_key
}
