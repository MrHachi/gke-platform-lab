locals {
  module = "gke-nodepool"
}

data "google_container_engine_versions" "gke_version" {
  version_prefix = var.gke_version_prefix
}

resource "google_container_node_pool" "primary_nodes" {
  name = "${var.cluster_name}-${var.name}"

  cluster    = var.cluster_name
  location   = var.location
  node_count = var.node_count

  # This is a lab, so we don't necessarily need STABLE releases (use REGULAR)
  version = data.google_container_engine_versions.gke_version.release_channel_default_version["REGULAR"]

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.stack}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      path = "${var.stack}/${local.module}/${var.cluster_name}"
    }
  }
}
