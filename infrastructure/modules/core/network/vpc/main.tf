locals {
  module = "vpc"
}

resource "google_compute_network" "main" {
  name                    = "${var.stack}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnet_config

  network = google_compute_network.main.name
  region  = each.value.region
  name    = "${var.stack}-subnet-${each.key}"

  ip_cidr_range = each.value.main

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary

    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }

  stack_type       = each.value.dualstack ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type = each.value.dualstack ? "EXTERNAL" : null

  private_ip_google_access   = true
  private_ipv6_google_access = "ENABLE_OUTBOUND_VM_TO_GOOGLE"
}
