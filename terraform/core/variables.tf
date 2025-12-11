variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)."
  type        = string
}

variable "config_file" {
  description = "Path to the YAML configuration file for this environment."
  type        = string
}
