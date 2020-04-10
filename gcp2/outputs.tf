output "photos_cronjob_sa_key" {
  value = google_service_account_key.photos_cronjob.private_key
}
