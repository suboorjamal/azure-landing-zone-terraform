locals {
  deploy               = var.enabled
  cfg                  = try(var.settings, {})
  enable_key_vault     = try(local.cfg.enable_key_vault, false)
  enable_auto_account  = try(local.cfg.enable_automation_account, false)
  location             = try(local.cfg.location, "eastus")
  resource_group_name  = "rg-shared-${var.environment}"
  key_vault_name       = "kv-shared-${var.environment}"
  automation_name      = "aa-shared-${var.environment}"
  hub_vnet_id          = try(var.hub_outputs.virtual_network_id, null)
}

resource "azurerm_resource_group" "shared" {
  count = local.deploy && (local.enable_key_vault || local.enable_auto_account) ? 1 : 0

  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_key_vault" "shared" {
  count = local.deploy && local.enable_key_vault ? 1 : 0

  name                        = local.key_vault_name
  location                    = azurerm_resource_group.shared[0].location
  resource_group_name         = azurerm_resource_group.shared[0].name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  public_network_access_enabled = true

  # Optional: add private endpoints when hub vnet is available.
  # This can be expanded later using var.hub_outputs.virtual_network_id.
}

resource "azurerm_automation_account" "shared" {
  count = local.deploy && local.enable_auto_account ? 1 : 0

  name                = local.automation_name
  location            = azurerm_resource_group.shared[0].location
  resource_group_name = azurerm_resource_group.shared[0].name
  sku_name            = "Basic"
}

data "azurerm_client_config" "current" {}
