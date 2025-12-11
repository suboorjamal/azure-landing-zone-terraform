locals {
  root_management_group_id = format("/providers/Microsoft.Management/managementGroups/%s", local.root_id)
}

output "root_management_group_id" {
  description = "Root management group id for the landing zone."
  value       = local.deploy ? local.root_management_group_id : null
}

output "management_group_ids" {
  description = "Management group ids returned by the enterprise-scale module."
  value       = local.deploy ? try(module.enterprise_scale[0].management_group_ids, {}) : {}
}

output "connectivity_management_group_id" {
  description = "Connectivity management group id."
  value       = local.deploy ? try(module.enterprise_scale[0].management_group_ids.connectivity, null) : null
}

output "identity_management_group_id" {
  description = "Identity management group id."
  value       = local.deploy ? try(module.enterprise_scale[0].management_group_ids.identity, null) : null
}
