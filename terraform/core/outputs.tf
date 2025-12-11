output "root_management_group_id" {
  description = "Root management group id from enterprise-scale deployment."
  value       = local.mg_enabled ? module.alz_core[0].root_management_group_id : null
}

output "hub_virtual_network_name" {
  description = "Name of the hub virtual network."
  value       = local.hub_enabled ? module.hub_network[0].virtual_network_name : null
}

output "hub_virtual_network_id" {
  description = "Resource id of the hub virtual network."
  value       = local.hub_enabled ? module.hub_network[0].virtual_network_id : null
}

output "log_analytics_workspace_id" {
  description = "Resource id of the Log Analytics workspace."
  value       = local.logging_enabled ? module.logging_monitoring[0].log_analytics_workspace_id : null
}
