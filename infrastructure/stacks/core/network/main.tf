locals {
  stack  = "lab-network"
  region = "us-south1"
  zone   = "${local.region}-a" # only used for provider configuration presently

  gke_subnet_name                = "gke"
  gke_subnet_pods_range_name     = "pods"
  gke_subnet_services_range_name = "services"
}

module "vpc" {
  # TODO: pin to tag
  source = "git::https://github.com/MrHachi/gke-platform-lab.git//infrastructure/modules/core/network/vpc?ref=main"

  stack = local.stack

  subnet_config = {
    (local.gke_subnet_name) = {
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
