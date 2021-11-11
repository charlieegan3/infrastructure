output "photos_cronjob_sa_key" {
  value     = google_service_account_key.photos_cronjob.private_key
  sensitive = true
}

output "photos_cms_sa_key" {
  value     = google_service_account_key.photos_cms.private_key
  sensitive = true
}

output "music_uploader_sa_key" {
  value     = google_service_account_key.music_bigquery_uploader.private_key
  sensitive = true
}

output "static_sa_key" {
  value     = google_service_account_key.static.private_key
  sensitive = true
}
