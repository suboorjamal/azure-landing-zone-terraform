output "virtual_network_name" {
  description = "Name of the hub virtual network."
  value       = local.deploy ? azurerm_virtual_network.hub[0].name : null
}

output "virtual_network_id" {
  description = "Resource id of the hub virtual network."
  value       = local.deploy ? azurerm_virtual_network.hub[0].id : null
}

output "virtual_network_address_space" {
  description = "Address space of the hub virtual network."
  value       = local.deploy ? azurerm_virtual_network.hub[0].address_space : []
}

output "firewall_public_ip" {
  description = "Public IP of the Azure Firewall, if deployed."
  value       = local.deploy && local.create_firewall ? azurerm_public_ip.firewall[0].ip_address : null
}
