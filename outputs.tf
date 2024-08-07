output "id" {
  value       = azurerm_application_gateway.main.id
  description = "The application gateway configuration ID."
}

output "name" {
  value       = azurerm_application_gateway.main.name
  description = "The name of the application gateway."
}

output "resource_group_name" {
  value       = azurerm_application_gateway.main.resource_group_name
  description = "The name of the resource group in which to create the application gateway."
}

output "location" {
  value       = azurerm_application_gateway.main.location
  description = "The location/region where the application gateway is created."
}

output "tags" {
  value       = azurerm_application_gateway.main.tags
  description = "The tags assigned to the resource."
}

output "backend_address_pools" {
  value       = { for pool in azurerm_application_gateway.main.backend_address_pool : pool.name => pool }
  description = "Blocks containing configuration of each backend address pool."
}

output "ssl_certificates" {
  value       = azurerm_application_gateway.main.ssl_certificate
  sensitive   = true
  description = "Blocks containing configuration of each ssl certificate."
}

output "http_listeners" {
  value       = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }
  description = "Blocks containing configuration of each http listener."
}

output "backend_http_settings" {
  value       = azurerm_application_gateway.main.backend_http_settings
  description = "Blocks containing configuration of each backend http settings."
}

output "request_routing_rules" {
  value       = azurerm_application_gateway.main.request_routing_rule
  description = "Blocks containing configuration of each request routing rule."
}
