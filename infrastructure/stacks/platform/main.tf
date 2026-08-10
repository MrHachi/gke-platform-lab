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

  modules_path    = "git::https://github.com/MrHachi/gke-platform-lab.git//infrastructure/modules/platform"
  modules_version = "module/platform/v0.0.4"
}

module "zonal_gke" {
  source = "${local.modules_path}/zonal-gke?ref=${local.modules_version}"

  stack = local.stack

  gke_release_channel = "REGULAR"

  zone        = local.zone
  vpc_name    = local.network.vpc_name
  subnet_name = local.network.gke_subnet_name

  pods_range_name     = local.network.gke_subnet_pods_range_name
  services_range_name = local.network.gke_subnet_services_range_name
}

module "gke_nodepool" {
  source = "${local.modules_path}/gke-nodepool?ref=${local.modules_version}"

  stack = local.stack

  gke_release_channel = "REGULAR"

  name         = "primary"
  cluster_name = module.zonal_gke.cluster_name

  location           = local.zone
  gke_version_prefix = local.gke_version_prefix

  node_count = 1
}
