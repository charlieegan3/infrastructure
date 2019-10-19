resource "google_compute_address" "ingress" {
  provider = google-beta
  name     = "cluster-ingress-external"
  address  = "35.237.222.125"

  labels = {
    kubeip = google_container_cluster.main.name
  }
}

