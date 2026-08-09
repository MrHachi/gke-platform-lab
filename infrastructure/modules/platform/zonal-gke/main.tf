locals {
  module = "zonal-gke"

  gke_release_channels = [
    "RAPID", "REGULAR", "STABLE", "EXTENDED"
  ]

  cluster_name = "${var.stack}-gke"
}

resource "google_container_cluster" "main" {
  name = local.cluster_name

  location = var.zone

  # This is a lab, so we don't necessarily need STABLE releases (use REGULAR)
  # (Matches the setting on the nodepool module)
  release_channel {
    channel = var.gke_release_channel
  }

  # From the Hashicorp-provided tutorial:
  # "We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it."
  # ~ Hashicorp
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_name
  subnetwork = var.subnet_name
  # networking_mode = "VPC_NATIVE"
  #
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Only allow pods to talk to allowed pods (requires configuring policy manifests)
  network_policy {
    enabled = true
  }

  # Disable long-lived client certificates
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  enable_intranode_visibility = true
  # networking_mode = "VPC_NATIVE" (default)

  # enable_shielded_nodes = true (default)

  resource_labels = {
    stack  = var.stack
    module = local.module
    path   = "${var.stack}/${local.module}/${local.cluster_name}"
  }
}
