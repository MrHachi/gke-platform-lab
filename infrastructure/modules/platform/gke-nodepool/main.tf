locals {
  module = "gke-nodepool"

  gke_release_channels = [
    "RAPID", "REGULAR", "STABLE", "EXTENDED"
  ]

  nodepool_name = "${var.cluster_name}-${var.name}"
}

data "google_container_engine_versions" "gke_version" {
  version_prefix = var.gke_version_prefix
}

resource "google_container_node_pool" "primary_nodes" {
  name = local.nodepool_name

  cluster    = var.cluster_name
  location   = var.location
  node_count = var.node_count

  # This is a lab, so we don't necessarily need STABLE releases (use REGULAR)
  version = data.google_container_engine_versions.gke_version.release_channel_default_version[var.gke_release_channel]

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # preemptible  = true
    machine_type = var.machine_type
    tags         = ["gke-node", "${var.stack}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }



    resource_labels = {
      stack   = var.stack
      module  = local.module
      cluster = var.cluster_name
    }
  }
}
