locals {
  deploy                = var.enabled
  cfg                   = try(var.settings, {})
  workspace_name        = try(local.cfg.log_analytics_workspace_name, "log-${var.environment}-shared")
  retention_days        = try(local.cfg.retention_days, 90)
  location              = try(local.cfg.location, "eastus")
  enable_app_insights   = try(local.cfg.enable_application_insights, false)
  app_insights_name     = "appi-shared-${var.environment}"
  resource_group_name   = "rg-logging-${var.environment}"
}

resource "azurerm_resource_group" "logging" {
  count = local.deploy ? 1 : 0

  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_log_analytics_workspace" "shared" {
  count = local.deploy ? 1 : 0

  name                = local.workspace_name
  location            = azurerm_resource_group.logging[0].location
  resource_group_name = azurerm_resource_group.logging[0].name
  sku                 = "PerGB2018"
  retention_in_days   = local.retention_days
}

resource "azurerm_application_insights" "shared" {
  count = local.deploy && local.enable_app_insights ? 1 : 0

  name                = local.app_insights_name
  location            = azurerm_resource_group.logging[0].location
  resource_group_name = azurerm_resource_group.logging[0].name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.shared[0].id
}
