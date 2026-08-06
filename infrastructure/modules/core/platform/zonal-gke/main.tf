locals {
  module = "zonal-gke"
}

resource "google_container_cluster" "main" {
  name = "${var.stack}-gke"

  location = var.zone

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
}
