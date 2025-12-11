output "log_analytics_workspace_id" {
  description = "Resource id of the Log Analytics workspace."
  value       = local.deploy ? azurerm_log_analytics_workspace.shared[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = local.deploy ? azurerm_log_analytics_workspace.shared[0].name : null
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights (if deployed)."
  value       = local.deploy && local.enable_app_insights ? azurerm_application_insights.shared[0].instrumentation_key : null
}
