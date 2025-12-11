output "resource_group_name" {
  description = "Resource group for shared services."
  value       = local.deploy && (local.enable_key_vault || local.enable_auto_account) ? azurerm_resource_group.shared[0].name : null
}

output "key_vault_id" {
  description = "Shared Key Vault resource id."
  value       = local.deploy && local.enable_key_vault ? azurerm_key_vault.shared[0].id : null
}

output "automation_account_id" {
  description = "Automation Account resource id."
  value       = local.deploy && local.enable_auto_account ? azurerm_automation_account.shared[0].id : null
}
