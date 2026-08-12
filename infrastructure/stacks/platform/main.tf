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
  modules_version = "module/platform/v0.1.0"

  nodepools = {
    "infra" = {
      machine_type = "e2-medium"
      nodes        = 1
      location     = local.zone

      # From the docs: https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-separation#create_a_cluster_with_node_taints
      # components.gke.io/gke-managed-components=true:NoSchedule
      taints = [
        { key = "components.gke.io/gke-managed-components", value = "true", effect = "NO_SCHEDULE" }
      ]
      labels = {
        workload = "infra"
      }
    }
    "app" = {
      machine_type = "e2-small"
      nodes        = 2
      location     = local.zone

      # Not tainted because it's not really a problem if infra workloads spill over into this pool
      taints = []
      labels = {
        workload = "app"
      }
    }
  }
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
  for_each = local.nodepools
  source   = "${local.modules_path}/gke-nodepool?ref=${local.modules_version}"

  cluster_name = module.zonal_gke.cluster_name

  gke_release_channel = "REGULAR"

  stack              = local.stack
  gke_version_prefix = local.gke_version_prefix

  name         = each.key
  location     = each.value.location
  machine_type = each.value.machine_type
  node_count   = each.value.nodes

  taints            = each.value.taints
  kubernetes_labels = each.value.labels
}
