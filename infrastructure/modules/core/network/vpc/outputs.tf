output "vpc_name" {
  value       = google_compute_network.main.name
  description = "VPC name"
}

output "subnet_names" {
  value = {
    gke = google_compute_subnetwork.gke.name
  }
  description = "Names of the subnets created by this module"
}
