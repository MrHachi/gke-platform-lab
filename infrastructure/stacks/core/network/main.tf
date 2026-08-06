locals {
  stack = "lab-network"
}

module "vpc" {
  # TODO: pin to tag
  source = "git::https://github.com/MrHachi/gke-platform-lab.git//infrastructure/modules/core/network/vpc?ref=main"

  stack = local.stack

  cidr_ipv4 = {
    main     = "10.16.0.0/16"
    pods     = "10.17.0.0/16"
    services = "10.18.0.0/20"
  }
}
