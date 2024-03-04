resource "azurerm_resource_group" "rg" {
  name     = uuid()
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = azurerm_resource_group.rg.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = azurerm_resource_group.rg.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "application_gateway" {
  source              = "./module"
  name                = azurerm_resource_group.rg.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku = {
    tier     = "WAF_v2"
    size     = "WAF_v2"
    capacity = 1
  }
  subnet_id                 = azurerm_subnet.default.id
  frontend_ip_configuration = { public_ip_address_id = azurerm_public_ip.pip.id, private_ip_address = "10.0.0.10", private_ip_address_allocation = "Static" }
  backend_address_pools = [
    { name = "pool", ip_addresses = ["10.0.0.4", "10.0.0.5"] }
  ]
  http_listeners = [
    { name = "listener", frontend_ip_configuration = "Public", port = 80, protocol = "Http" }
  ]
  backend_http_settings = [
    { name = "backend", port = 80, protocol = "Http", request_timeout = 20 }
  ]
  request_routing_rules = [
    { name = "rule", http_listener_name = "listener", backend_address_pool_name = "pool", backend_http_settings_name = "backend" }
  ]
}
