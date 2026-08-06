locals {
  stack  = "lab-platform"
  region = "us-south1" # MUST match GKE subnet region
  zone   = "${local.region}-a"

  network = {
    vpc_name                       = data.terraform_remote_state.network.outputs.vpc_name
    gke_subnet_name                = data.terraform_remote_state.network.outputs.gke_subnet_name
    gke_subnet_pods_range_name     = data.terraform_remote_state.network.outputs.gke_subnet_pods_range_name
    gke_subnet_services_range_name = data.terraform_remote_state.network.outputs.gke_subnet_services_range_name
  }

  gke_version_prefix = "1.36."
}

module "zonal_gke" {
  # TODO: pin to tag
  source = "git::https://github.com/MrHachi/gke-platform-lab.git//infrastructure/modules/core/platform/zonal-gke?ref=main"

  stack = local.stack

  zone        = local.zone
  vpc_name    = local.network.vpc_name
  subnet_name = local.network.gke_subnet_name

  pods_range_name     = local.network.gke_subnet_pods_range_name
  services_range_name = local.network.gke_subnet_services_range_name
}

module "gke_nodepool" {
  # TODO: pin to tag
  source = "git::https://github.com/MrHachi/gke-platform-lab.git//infrastructure/modules/core/platform/gke-nodepool?ref=main"

  stack = local.stack

  name         = "primary"
  cluster_name = module.zonal_gke.cluster_name

  location           = local.zone
  gke_version_prefix = local.gke_version_prefix

  node_count = 1
}
