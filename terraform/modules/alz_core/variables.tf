variable "enabled" {
  description = "Toggle to deploy or skip the ALZ (CAF enterprise-scale) module."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)."
  type        = string
}

variable "management_groups" {
  description = "Management group configuration block."
  type        = any
  default     = {}
}

variable "policy_config" {
  description = "Policy configuration block."
  type        = any
  default     = {}
}

variable "feature_flags" {
  description = "Feature flags controlling ALZ optional deployments."
  type        = any
  default     = {}
}
