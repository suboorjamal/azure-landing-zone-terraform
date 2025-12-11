variable "enabled" {
  description = "Toggle deployment of the hub network."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)."
  type        = string
}

variable "hub_settings" {
  description = "Hub network configuration block from YAML."
  type        = any
  default     = {}
}

variable "root_mg_id" {
  description = "Root management group id (optional, for policy linkage)."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace id for diagnostics."
  type        = string
  default     = null
}
