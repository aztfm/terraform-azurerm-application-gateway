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

module "virtual_network" {
  source              = "aztfm/virtual-network/azurerm"
  version             = ">=4.0.0"
  name                = "virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  subnets = [{
    name             = "subnet"
    address_prefixes = ["10.0.0.0/24"]
  }]
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
  subnet_id           = module.virtual_network.subnet["subnet"].id
  capacity            = 1
  frontend_ip_configuration = {
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  backend_address_pools = [{
    name         = "backend-address-pool",
    ip_addresses = ["10.0.0.4", "10.0.0.5"]
  }]
  http_listeners = [{
    name                      = "http-listener"
    frontend_ip_configuration = "Public"
    protocol                  = "Http"
    port                      = 80
  }]
  backend_http_settings = [{
    name     = "backend-http-setting-1"
    protocol = "Http"
    port     = 80
  }]
  request_routing_rules = [{
    name                       = "request-routing-rule"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-setting"
  }]
}
