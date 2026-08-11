variable "stack" {
  type        = string
  description = "Stack name"
}

variable "location" {
  type        = string
  description = "Zone or region in which to create this nodepool"
}

variable "name" {
  type        = string
  description = "Name of the nodepool (will be suffixed onto the cluster_name)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to which this nodepool belongs"
}

variable "gke_version_prefix" {
  type        = string
  description = "GKE version to use for this nodepool"

  validation {
    condition     = can(regex("^[0-9]+\\.(?:[0-9]+\\.)?$", var.gke_version_prefix))
    error_message = "Specify a GKE version prefix of the form \"#.\" or \"#.#.\""
  }
}

variable "node_count" {
  type        = number
  description = "Number of nodes to create in this nodepool"

  validation {
    condition     = var.node_count > 0 && floor(var.node_count) == var.node_count
    error_message = "Specify an integer node count greater than 0"
  }
}

variable "gke_release_channel" {
  type        = string
  description = "GKE release channel to use"

  validation {
    condition     = contains(local.gke_release_channels, var.gke_release_channel)
    error_message = "Use a value from: ${join(", ", local.gke_release_channels)}"
  }
}

variable "machine_type" {
  type        = string
  description = "Machine type to use for the nodes in this node pool"
}

variable "kubernetes_labels" {
  type        = map(string)
  default     = {}
  description = "Map of key/value pairs used to set kubernetes labels on the nodes in this node pool"
}

variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default     = []
  description = "List of taint configurations to set on the nodes in this node pool"

  validation {
    condition = alltrue([
      for taint in var.taints : contains(local.taint_effects, taint.effect)
    ])
    error_message = "Please specify one of the following values for taint effect: ${join(", ", local.taint_effects)}"
  }
}
