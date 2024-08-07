data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.workspace_id
  location = "Spain Central"
  tags = {
    "Origin"     = "GitHub"
    "Project"    = "Azure Terraform Modules (aztfm)"
    "Repository" = "terraform-azurerm-application-gateway"
  }
}

#region Basic resources

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

resource "azurerm_public_ip" "pip" {
  name                = local.workspace_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags
  zones               = [1, 2, 3]
  allocation_method   = "Static"
  sku                 = "Standard"
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

#region Certificate

resource "tls_private_key" "cer" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cer" {
  private_key_pem       = tls_private_key.cer.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 1
  allowed_uses          = ["digital_signature", "cert_signing", "crl_signing"]

  subject {
    common_name = "TLSInspection"
  }
}

resource "pkcs12_from_pem" "cer" {
  cert_pem        = tls_self_signed_cert.cer.cert_pem
  private_key_pem = tls_private_key.cer.private_key_pem
  password        = local.workspace_id
}

resource "azurerm_user_assigned_identity" "id" {
  name                = local.workspace_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_key_vault" "kv" {
  name                      = "a${substr(local.workspace_id, 0, 22)}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  tags                      = azurerm_resource_group.rg.tags
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "spn" {
  scope                = azurerm_key_vault.kv.id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
}

resource "azurerm_role_assignment" "id" {
  scope                = azurerm_key_vault.kv.id
  principal_id         = azurerm_user_assigned_identity.id.principal_id
  role_definition_name = "Key Vault Certificate User"
}

resource "azurerm_key_vault_certificate" "kv" {
  depends_on   = [azurerm_role_assignment.spn]
  name         = "${local.workspace_id}1"
  key_vault_id = azurerm_key_vault.kv.id

  certificate {
    contents = pkcs12_from_pem.cer.result
    password = local.workspace_id
  }
}
