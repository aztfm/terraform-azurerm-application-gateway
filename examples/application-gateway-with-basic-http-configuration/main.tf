provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "terraform-azurerm-application-gateway"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "application-gateway" {
  source                    = "aztfm/application-gateway/azurerm"
  version                   = "1.0.0"
  name                      = "application-gateway"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  sku                       = { tier = "WAF_v2", size = "WAF_v2", capacity = 2 }
  subnet_id                 = azurerm_subnet.subnet.id
  frontend_ip_configuration = { public_ip_address_id = azurerm_public_ip.pip.id, private_ip_address = "10.0.0.10", private_ip_address_allocation = "Static" }
  backend_address_pools = [
    { name = "backend-address-pool-1" },
    { name = "backend-address-pool-2", ip_addresses = "10.0.0.4,10.0.0.5,10.0.0.6" }
  ]
  http_listeners        = [{ name = "http-listener", frontend_ip_configuration = "Public", port = 80, protocol = "http" }]
  backend_http_settings = [{ name = "backend-http-setting", port = 80, protocol = "http", request_timeout = 20 }]
  request_routing_rules = [
    {
      name                       = "request-routing-rule-1"
      http_listener_name         = "http-listener"
      backend_address_pool_name  = "backend-address-pool-1"
      backend_http_settings_name = "backend-http-setting"
    },
    {
      name                       = "request-routing-rule-2"
      http_listener_name         = "http-listener"
      backend_address_pool_name  = "backend-address-pool-2"
      backend_http_settings_name = "backend-http-setting"
    }
  ]
}
