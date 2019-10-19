resource "google_dns_managed_zone" "charlieegan3com" {
  name        = "charlieegan3com"
  dns_name    = "charlieegan3.com."
  description = "DNS zone for charlieegan3.com"
}

resource "google_dns_record_set" "bare" {
  name = google_dns_managed_zone.charlieegan3com.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.charlieegan3com.name

  rrdatas = ["35.237.222.125"]
}

resource "google_dns_record_set" "wildcard" {
  name = "*.${google_dns_managed_zone.charlieegan3com.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.charlieegan3com.name

  rrdatas = ["35.237.222.125"]
}

resource "google_dns_record_set" "mx" {
  name         = google_dns_managed_zone.charlieegan3com.dns_name
  managed_zone = google_dns_managed_zone.charlieegan3com.name
  type         = "MX"
  ttl          = 3600

  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ]
}

resource "google_dns_record_set" "txt-verification" {
  name         = google_dns_managed_zone.charlieegan3com.dns_name
  managed_zone = google_dns_managed_zone.charlieegan3com.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = [
    "\"keybase-site-verification=WxfnZR-p3nQsDqH1_ilKFMGS13-LnMlGPQ3fg3lOWcQ\"",
    "\"v=spf1 include:_spf.google.com ~all\"",
    "\"google-site-verification=cBz1vO6h2fvtz4FMtm27PAqLdkTh1SM0-z-aRo92K-M\"",
  ]
}

resource "google_dns_record_set" "txt-domainkey" {
  name         = "20161022200133pm._domainkey.${google_dns_managed_zone.charlieegan3com.dns_name}"
  managed_zone = google_dns_managed_zone.charlieegan3com.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = [
    "\"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3jfeS5Uh/rgG0SWX4SCYhMud9WpyLT/xU7+nceVjIvMyWtzmiG8+OoDvsENi/Mga4PM7VwfFhc6nxmIuhiJ33v9oJ5W21DQzo+kzLLvUIGKELkwLgesnvJLVKmMZSGlfbne04XW5JlgzqYQtjKgqk5yqa/CB4jU9AtKL/7QdTUwIDAQAB\"",
  ]
}

resource "google_dns_record_set" "txt-mail-id" {
  name         = "google._domainkey.${google_dns_managed_zone.charlieegan3com.dns_name}"
  managed_zone = google_dns_managed_zone.charlieegan3com.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = [
    "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCm/xldnDzZCUNYHPDAuUn+MFtHyUT6YwxBfch9FKMO2up7cx8kMzurz9OO+KD+R3DOwSiALVoLwti2dbHZny1gwDfeqrrCvPQtLzuhsOEIAJWKAJFAqsltBxVj4G4NeQF0upAD5wpAlxoshJwRU33DvkQyNEvT8aGhpwYqWcUtFwIDAQAB\"",
  ]
}
