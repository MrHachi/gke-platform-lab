variable "stack" {
  type        = string
  description = "Stack name"
}

variable "cidr_ipv4" {
  type = object({
    main     = string
    pods     = string
    services = string
  })
  description = "IPv4 CIDR blocks for the VPC subnetwork"

  validation {
    condition     = can(cidrhost(var.cidr_ipv4.main, 0)) && can(regex("^[0-9.]+/[0-9]+$", var.cidr_ipv4.main))
    error_message = "var.cidr_ipv4.main must be a valid IPv4 CIDR block"
  }

  validation {
    condition     = can(cidrhost(var.cidr_ipv4.pods, 0)) && can(regex("^[0-9.]+/[0-9]+$", var.cidr_ipv4.pods))
    error_message = "var.cidr_ipv4.pods must be a valid IPv4 CIDR block"
  }

  validation {
    condition     = can(cidrhost(var.cidr_ipv4.services, 0)) && can(regex("^[0-9.]+/[0-9]+$", var.cidr_ipv4.services))
    error_message = "var.cidr_ipv4.services must be a valid IPv4 CIDR block"
  }
}
