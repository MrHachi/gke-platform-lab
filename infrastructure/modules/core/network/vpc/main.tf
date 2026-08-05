locals {
  module = "vpc"
}

resource "google_compute_network" "main" {
  name                    = "${var.stack}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "gke" {
  network = google_compute_network.main.name
  name    = "${var.stack}-subnet-1"

  stack_type    = "IPV4_IPV6"
  ip_cidr_range = var.cidr_ipv4.main
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.cidr_ipv4.pods
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.cidr_ipv4.services
  }
  ipv6_access_type         = "EXTERNAL"
  private_ip_google_access = true
}
