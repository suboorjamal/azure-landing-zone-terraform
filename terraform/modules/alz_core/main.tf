terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
      ]
    }
  }
}


locals {
  deploy           = var.enabled
  mg               = try(var.management_groups, {})
  policy           = try(var.policy_config, {})
  flags            = try(var.feature_flags, {})
  default_location = try(local.mg.default_location, "eastus")
  root_id          = try(local.mg.root_id, "contoso")
  root_name        = try(local.mg.root_name, "Contoso Root")
  policy_enabled   = try(local.policy.enable_policies, true)
}

data "azurerm_client_config" "current" {}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = ">= 4.0.0"
  count   = local.deploy ? 1 : 0

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }

  default_location = local.default_location
  root_id          = local.root_id
  root_name        = local.root_name
  root_parent_id   = try(local.mg.root_parent_id, data.azurerm_client_config.current.tenant_id)

  deploy_management_resources   = try(local.flags.deploy_management_resources, false)
  deploy_connectivity_resources = try(local.flags.deploy_connectivity_resources, false)
  deploy_identity_resources     = try(local.flags.deploy_identity_resources, false)

  deploy_core_landing_zones   = try(local.flags.deploy_core_landing_zones, true) && local.policy_enabled
  deploy_corp_landing_zones   = try(local.flags.deploy_corp_landing_zones, false)
  deploy_online_landing_zones = try(local.flags.deploy_online_landing_zones, false)
  deploy_sap_landing_zones    = try(local.flags.deploy_sap_landing_zones, false)

  subscription_id_management   = try(local.mg.subscription_id_management, null)
  subscription_id_connectivity = try(local.mg.subscription_id_connectivity, null)
  subscription_id_identity     = try(local.mg.subscription_id_identity, null)
}
