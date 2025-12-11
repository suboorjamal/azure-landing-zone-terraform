locals {
  deploy              = var.enabled
  hub                 = try(var.hub_settings, {})
  address_space       = try(local.hub.address_space, "10.0.0.0/16")
  dns_servers         = try(local.hub.dns_servers, [])
  create_firewall     = try(local.hub.create_azure_firewall, false)
  create_vpn_gateway  = try(local.hub.create_vpn_gateway, false)
  create_er_gateway   = try(local.hub.create_er_gateway, false)
  location            = try(local.hub.location, "eastus")
  default_subnet_cidr = cidrsubnet(local.address_space, 8, 0)
  firewall_subnet_cidr = cidrsubnet(local.address_space, 8, 1)
  gateway_subnet_cidr  = cidrsubnet(local.address_space, 8, 2)
}

resource "azurerm_resource_group" "hub" {
  count = local.deploy ? 1 : 0

  name     = "rg-hub-${var.environment}"
  location = local.location
}

resource "azurerm_virtual_network" "hub" {
  count = local.deploy ? 1 : 0

  name                = "vnet-hub-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  address_space       = [local.address_space]
  dns_servers         = length(local.dns_servers) > 0 ? local.dns_servers : null
}

resource "azurerm_subnet" "default" {
  count = local.deploy ? 1 : 0

  name                 = "default"
  resource_group_name  = azurerm_resource_group.hub[0].name
  virtual_network_name = azurerm_virtual_network.hub[0].name
  address_prefixes     = [local.default_subnet_cidr]
}

resource "azurerm_subnet" "firewall" {
  count = local.deploy && local.create_firewall ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub[0].name
  virtual_network_name = azurerm_virtual_network.hub[0].name
  address_prefixes     = [local.firewall_subnet_cidr]
}

resource "azurerm_subnet" "gateway" {
  count = local.deploy && (local.create_vpn_gateway || local.create_er_gateway) ? 1 : 0

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub[0].name
  virtual_network_name = azurerm_virtual_network.hub[0].name
  address_prefixes     = [local.gateway_subnet_cidr]
}

resource "azurerm_public_ip" "firewall" {
  count = local.deploy && local.create_firewall ? 1 : 0

  name                = "pip-fw-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  count = local.deploy && local.create_firewall ? 1 : 0

  name                = "fw-hub-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }
}

resource "azurerm_public_ip" "vpn_gw" {
  count = local.deploy && local.create_vpn_gateway ? 1 : 0

  name                = "pip-vpngw-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "vpn" {
  count = local.deploy && local.create_vpn_gateway ? 1 : 0

  name                = "vng-vpn-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw[0].id
    private_ip_allocation_method  = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway[0].id
  }
}

resource "azurerm_public_ip" "er_gw" {
  count = local.deploy && local.create_er_gateway ? 1 : 0

  name                = "pip-ergw-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "er" {
  count = local.deploy && local.create_er_gateway ? 1 : 0

  name                = "vng-er-${var.environment}"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name

  type = "ExpressRoute"
  sku  = "Standard"

  ip_configuration {
    name                         = "vnetGatewayConfig"
    public_ip_address_id         = azurerm_public_ip.er_gw[0].id
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.gateway[0].id
  }
}
