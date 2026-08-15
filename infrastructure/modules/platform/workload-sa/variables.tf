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