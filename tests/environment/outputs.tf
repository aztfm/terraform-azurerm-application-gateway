output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "workspace_id" {
  value = local.workspace_id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}

output "public_ip_id" {
  value = azurerm_public_ip.pip.id
}

output "subnet_id" {
  value = azurerm_subnet.snet.id
}
