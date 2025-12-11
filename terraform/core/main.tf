locals {
  lz_config          = yamldecode(file(var.config_file))
  management_groups  = try(local.lz_config.management_groups, {})
  policy             = try(local.lz_config.policy, {})
  hub_network        = try(local.lz_config.hub_network, {})
  shared_services    = try(local.lz_config.shared_services, {})
  logging_monitoring = try(local.lz_config.logging_monitoring, {})
  feature_flags      = try(local.lz_config.feature_flags, {})

  mg_enabled      = try(local.management_groups.enabled, false)
  hub_enabled     = try(local.hub_network.enabled, false)
  shared_enabled  = try(local.shared_services.enabled, false)
  logging_enabled = try(local.logging_monitoring.enabled, false)
}

module "alz_core" {
  count  = local.mg_enabled ? 1 : 0
  source = "../modules/alz_core"

  enabled            = local.mg_enabled
  environment        = var.environment
  management_groups  = local.management_groups
  policy_config      = local.policy
  feature_flags      = local.feature_flags
}

module "hub_network" {
  count  = local.hub_enabled ? 1 : 0
  source = "../modules/hub_network"

  enabled     = local.hub_enabled
  environment = var.environment
  hub_settings = local.hub_network
  root_mg_id   = local.mg_enabled ? module.alz_core[0].root_management_group_id : null
}

module "shared_services" {
  count  = local.shared_enabled ? 1 : 0
  source = "../modules/shared_services"

  enabled     = local.shared_enabled
  environment = var.environment
  settings    = local.shared_services
  hub_outputs = local.hub_enabled ? {
    virtual_network_id   = try(module.hub_network[0].virtual_network_id, null)
    virtual_network_name = try(module.hub_network[0].virtual_network_name, null)
  } : {}
}

module "logging_monitoring" {
  count  = local.logging_enabled ? 1 : 0
  source = "../modules/logging_monitoring"

  enabled     = local.logging_enabled
  environment = var.environment
  settings    = local.logging_monitoring
}
