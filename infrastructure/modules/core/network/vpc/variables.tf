variable "stack" {
  type        = string
  description = "Stack name"
}

variable "subnet_config" {
  type = map(object({
    main      = string
    secondary = map(string)
    dualstack = optional(bool, false)
  }))
  description = "Map of subnet names IPv4 CIDR block configurations for the VPC subnetwork"

  validation {
    condition = alltrue(flatten(
      [
        for _, cfg in var.subnet_config :
        concat(
          [can(cidrhost(cfg.main, 0))],
          [for _, cidr in cfg.secondary : can(cidrhost(cidr, 0))]
        )
      ]
    ))
    error_message = "All main and secondary CIDRs must be valid IPv4 CIDR blocks."
  }
}
