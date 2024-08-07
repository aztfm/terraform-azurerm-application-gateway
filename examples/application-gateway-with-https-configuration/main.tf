data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "resource-group"
  location = "Spain Central"
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "snet" {
  name                 = "virtual-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

module "application_gateway_firewall_policy" {
  source              = "aztfm/application-gateway-firewall-policy/azurerm"
  version             = ">=1.0.0"
  name                = "application-gateway-firewall-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  managed_rule_sets = [{
    type    = "OWASP"
    version = "3.2"
    }, {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }]
}

module "application_gateway" {
  source              = "aztfm/application-gateway/azurerm"
  version             = ">=2.0.0"
  name                = "application-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "WAF_v2"
  firewall_policy_id  = module.application_gateway_firewall_policy.id
  capacity            = 1
  subnet_id           = azurerm_subnet.snet.id
  frontend_ip_configuration = {
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  backend_address_pools = [{
    name         = "backend-address-pool",
    ip_addresses = ["10.0.0.4", "10.0.0.5"]
  }]
  ssl_certificates = [{
    name     = "certificate"
    data     = filebase64("path/to/file")
    password = "P4$$w0rd1234"
  }]
  http_listeners = [{
    name                      = "http-listener"
    frontend_ip_configuration = "Public"
    protocol                  = "Https"
    port                      = 443
    certificate_name          = "certificate"
  }]
  backend_http_settings = [{
    name     = "backend-http-setting"
    protocol = "Https"
    port     = 443
  }]
  request_routing_rules = [{
    name                       = "request-routing-rule"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-setting"
  }]
}
