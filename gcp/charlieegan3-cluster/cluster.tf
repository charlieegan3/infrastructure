data "google_container_engine_versions" "versions" {
  location = var.cluster_zone

  # if patch version is set, then look for gke suffix, otherwise, look for any suffix
  version_prefix = length(regexall("^\\d+\\.\\d+\\.\\d+$", var.cluster_version)) > 0 ? "${var.cluster_version}-" : "${var.cluster_version}."
}

locals {
  # use the supplied cluster version if it is complete, otherwise use latest
  # with prefix.
  master_version = length(regexall("^[\\d\\.]+-gke\\.\\d+$", var.cluster_version)) > 0 ? var.cluster_version : data.google_container_engine_versions.versions.latest_master_version
  node_version   = length(regexall("^[\\d\\.]+-gke\\.\\d+$", var.cluster_version)) > 0 ? var.cluster_version : data.google_container_engine_versions.versions.latest_node_version
}

resource "google_container_cluster" "main" {
  provider = google-beta

  name     = "main"
  location = var.cluster_zone
  project  = var.project_id

  min_master_version = local.master_version

  remove_default_node_pool = true

  lifecycle {
    ignore_changes = [node_pool]
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }

    istio_config {
      disabled = true
    }
  }

  resource_usage_export_config {
    enable_network_egress_metering = false

    bigquery_destination {
      dataset_id = "cluster_usage"
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  monitoring_service = "none"
  logging_service    = "none"
}

resource "google_container_node_pool" "ingress" {
  provider = google-beta

  name       = "ingress"
  location   = var.cluster_zone
  cluster    = google_container_cluster.main.name
  project    = var.project_id
  node_count = 1

  version = local.node_version

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    preemptible  = false
    machine_type = "f1-micro"
    disk_size_gb = 20

    taint {
      key    = "ingress"
      value  = "true"
      effect = "NO_EXECUTE"
    }

    labels = {
      ingress = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }
}

resource "google_container_node_pool" "main" {
  provider = google-beta

  name       = "main"
  location   = var.cluster_zone
  cluster    = google_container_cluster.main.name
  project    = var.project_id
  node_count = 2

  version = local.node_version

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"
    disk_size_gb = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }
}
