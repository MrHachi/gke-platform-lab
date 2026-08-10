locals {
  stack  = "lab-network"
  region = "us-south1"
  zone   = "${local.region}-a" # only used for provider configuration presently

  gke_subnet_id                  = "gke"
  gke_subnet_pods_range_name     = "pods"
  gke_subnet_services_range_name = "services"

  modules_path    = "git::https://github.com/MrHachi/gke-platform-lab.git//infrastructure/modules/network"
  modules_version = "module/network/v0.0.2"
}

module "vpc" {
  source = "${local.modules_path}/vpc?ref=${local.modules_version}"

  stack = local.stack

  subnet_config = {
    (local.gke_subnet_id) = {
      region = local.region
      main   = "10.16.0.0/16"
      secondary = {
        (local.gke_subnet_pods_range_name)     = "10.17.0.0/16"
        (local.gke_subnet_services_range_name) = "10.18.0.0/20"
      }
      dualstack = true
    }
  }
}
