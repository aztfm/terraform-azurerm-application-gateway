provider "azurerm" {
  features {}
}

run "setup" {
  module {
    source = "./tests/environment"
  }
}

variables {
  sku = {
    name = "WAF_v2"
    tier = "WAF_v2"
  }
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

run "apply" {
  command = plan

  variables {
    name                      = run.setup.workspace_id
    resource_group_name       = run.setup.resource_group_name
    location                  = run.setup.resource_group_location
    subnet_id                 = run.setup.subnet_id
    frontend_ip_configuration = {
      public_ip_address_id = run.setup.public_ip_id
    }
  }

  assert {
    condition     = azurerm_application_gateway.main.name == run.setup.workspace_id
    error_message = ""
  }

  assert {
    condition     = azurerm_application_gateway.main.resource_group_name == run.setup.resource_group_name
    error_message = ""
  }

  assert {
    condition     = azurerm_application_gateway.main.location == run.setup.resource_group_location
    error_message = ""
  }
}

// run "apply" {
//   command = plan

//   variables { 
//     name                = run.setup.workspace_id
//     resource_group_name = run.setup.resource_group_name
//     location            = run.setup.resource_group_location
//    }
// }
