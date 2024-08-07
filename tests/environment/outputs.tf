output "workspace_id" {
  value = local.workspace_id
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}

output "resource_group_tags" {
  value = azurerm_resource_group.rg.tags
}

output "firewall_policy_id" {
  value = azurerm_web_application_firewall_policy.waf.id
}

output "subnet_id" {
  value = azurerm_subnet.snet.id
}

output "subnet_address_prefix" {
  value = azurerm_subnet.snet.address_prefixes[0]
}

output "public_ip_id" {
  value = azurerm_public_ip.pip.id
}

output "managed_identity_id" {
  value = azurerm_user_assigned_identity.id.id
}

output "certificate_data" {
  value = pkcs12_from_pem.cer.result
}

output "key_vault_certificate_secret_id" {
  value = azurerm_key_vault_certificate.kv.versionless_secret_id
}
