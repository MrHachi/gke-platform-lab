output "vpc_name" {
  value       = google_compute_network.main.name
  description = "VPC name"
}

output "subnet_config" {
  value = {
    for id, subnet in google_compute_subnetwork.subnet :
    id => {
      name                = subnet.name
      region              = subnet.region
      main_cidr_ipv4      = subnet.ip_cidr_range
      secondary_cidr_ipv4 = var.subnet_config[name].secondary # not exposed via attributes-needs to be taken from vars
      cidr_ipv6           = subnet.ipv6_cidr_range
    }
  }
  description = "Map of subnet names to configuration"
}
