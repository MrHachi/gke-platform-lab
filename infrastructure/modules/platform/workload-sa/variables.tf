variable "stack" {
  type        = string
  description = "Stack name"
}

variable "id" {
  type        = string
  description = "ID of the service account"
}

variable "display_name" {
  type        = string
  default     = null
  description = "Display name of the service account"
}

variable "description" {
  type        = string
  default     = null
  description = "Service account description"
}

variable "workload_namespace" {
  type        = string
  description = "Namespace of the GKE workload that will assume this service account"
}

variable "workload_sa" {
  type        = string
  description = "Name of the GKE workload's service account that will assume this GCP service account"
}
