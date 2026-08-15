variable "stack" {
  type        = string
  description = "Stack name"
}

variable "name_base" {
  type        = string
  description = "Base of the name to give the bucket (will be prefixed with stack name and suffixed with project number"
}

variable "location" {
  type        = string
  description = "Location in which to create the bucket (zones can only be used with Rapid Buckets)"
}

variable "object_expiry" {
  type = object({
    days = number
  })
  default = null

  description = "Bucket object expiry configuration"
}

variable "accessors" {
  type = map(object({
    role = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }), null)
  }))
  default = {}

  description = "Map of members to objects defining the role they have on the bucket and any conditions"
}
