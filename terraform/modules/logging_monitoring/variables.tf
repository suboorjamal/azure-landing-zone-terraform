variable "enabled" {
  description = "Toggle deployment of logging and monitoring resources."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)."
  type        = string
}

variable "settings" {
  description = "Logging and monitoring configuration block from YAML."
  type        = any
  default     = {}
}
