output "id" {
  value       = azurerm_application_gateway.appgw.id
  description = "The application gateway configuration ID."
}

output "name" {
  value       = azurerm_application_gateway.appgw.name
  description = "The name of the application gateway."
}

output "resource_group_name" {
  value       = azurerm_application_gateway.appgw.resource_group_name
  description = "The name of the resource group in which to create the application gateway."
}

output "location" {
  value       = azurerm_application_gateway.appgw.location
  description = "The location/region where the application gateway is created."
}

output "backend_address_pools" {
  value       = azurerm_application_gateway.appgw.backend_address_pool
  description = "Blocks containing configuration of each backend address pool."
}

output "ssl_certificates" {
  value       = azurerm_application_gateway.appgw.ssl_certificate
  description = "Blocks containing configuration of each ssl certificate."
}

output "http_listeners" {
  value       = azurerm_application_gateway.appgw.http_listener
  description = "Blocks containing configuration of each http listener."
}

output "backend_http_settings" {
  value       = azurerm_application_gateway.appgw.backend_http_settings
  description = "Blocks containing configuration of each backend http settings."
}

output "request_routing_rules" {
  value       = azurerm_application_gateway.appgw.request_routing_rule
  description = "Blocks containing configuration of each request routing rule."
}

output "tags" {
  value       = azurerm_application_gateway.appgw.tags
  description = "The tags assigned to the resource."
}
