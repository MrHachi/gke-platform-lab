output "vpc_name" {
  value = module.vpc.vpc_name
}

output "gke_subnet_name" {
  value = module.vpc.subnet_config[local.gke_subnet_id].name
}

output "gke_subnet_pods_range_name" {
  value = local.gke_subnet_pods_range_name
}

output "gke_subnet_services_range_name" {
  value = local.gke_subnet_services_range_name
}
