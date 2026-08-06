output "vpc_name" {
  value = module.vpc.vpc_name
}

output "gke_subnet_name" {
  value = module.vpc.subnet_names.gke
}
