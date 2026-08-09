variable "stack" {
  type        = string
  description = "Stack name"
}

variable "zone" {
  type        = string
  description = "Zone to create the cluster in"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to create the zonal cluster in"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet to create the zonal cluster in"
}

variable "pods_range_name" {
  type        = string
  description = "Secondary subnet range name for GKE pods"
}

variable "services_range_name" {
  type        = string
  description = "Secondary subnet range name for GKE services"
}

variable "gke_release_channel" {
  type        = string
  description = "GKE release channel to use"

  validation {
    condition     = contains(local.gke_release_channels, var.gke_release_channel)
    error_message = "Use a value from: ${join(",", local.gke_release_channels)}"
  }
}
