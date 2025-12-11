variable "enabled" {
  description = "Toggle deployment of shared services."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)."
  type        = string
}

variable "settings" {
  description = "Shared services configuration block from YAML."
  type        = any
  default     = {}
}

variable "hub_outputs" {
  description = "Optional hub network outputs for integration (e.g., private endpoints)."
  type = object({
    virtual_network_id   = optional(string)
    virtual_network_name = optional(string)
  })
  default = {}
}
