resource "azurerm_resource_group" "rg" {
  name     = local.workspace_id
  location = "Spain Central"
  tags = {
    "Origin"     = "GitHub"
    "Project"    = "Azure Terraform Modules (aztfm)"
    "Repository" = "terraform-azurerm-application-gateway"
  }
}

resource "azurerm_web_application_firewall_policy" "waf" {
  name                = local.workspace_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.workspace_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "snet" {
  name                 = local.workspace_id
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = local.workspace_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags
  zones               = [1, 2, 3]
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_user_assigned_identity" "id_01" {
  name                = "${local.workspace_id}1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_user_assigned_identity" "id_02" {
  name                = "${local.workspace_id}2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags
}
