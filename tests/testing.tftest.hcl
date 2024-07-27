provider "azurerm" {
  features {}
}

run "setup" {
  module {
    source = "./tests/environment"
  }
}

variables {
  sku_name     = "WAF_v2"
  zones        = [1, 2, 3]
  enable_http2 = true
  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 5
  }
  backend_address_pools = [{
    name = "backend-address-pool-1"
    }, {
    name  = "backend-address-pool-2"
    fqdns = ["domini1.com", "domini2.com"]
    }, {
    name         = "backend-address-pool-3"
    ip_addresses = ["10.0.10.1", "192.16.0.4"]
  }]
  http_listeners = [{
    name                      = "http-listener-1"
    frontend_ip_configuration = "Public"
    port                      = 80
    protocol                  = "Http"
    },
    #   {
    #   name                      = "http-listener-2"
    #   frontend_ip_configuration = "Public"
    #   port                      = 80
    #   protocol                  = "Http"
    # }
  ]
  backend_http_settings = [{ name = "backend-http-setting", port = 80, protocol = "Http", request_timeout = 20 }]
  request_routing_rules = [{
    name                       = "request-routing-rule-1"
    priority                   = 1
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-address-pool-1"
    backend_http_settings_name = "backend-http-setting"
    },
    #    {
    #   name                       = "request-routing-rule-2"
    #   priority                   = 2
    #   http_listener_name         = "http-listener-2"
    #   backend_address_pool_name  = "backend-address-pool-2"
    #   backend_http_settings_name = "backend-http-setting"
    # }
  ]
}

run "plan" {
  command = plan

  variables {
    name                = run.setup.workspace_id
    resource_group_name = run.setup.resource_group_name
    location            = run.setup.resource_group_location
    tags                = run.setup.resource_group_tags
    firewall_policy_id  = run.setup.firewall_policy_id
    subnet_id           = run.setup.subnet_id
    frontend_ip_configuration = {
      public_ip_address_id = run.setup.public_ip_id
    }
  }

  assert {
    condition     = azurerm_application_gateway.main.name == run.setup.workspace_id
    error_message = "The Application Gateway name input variable is being modified."
  }

  assert {
    condition     = azurerm_application_gateway.main.resource_group_name == run.setup.resource_group_name
    error_message = "The Application Gateway resource group input variable is being modified."
  }

  assert {
    condition     = azurerm_application_gateway.main.location == run.setup.resource_group_location
    error_message = "The Application Gateway location input variable is being modified."
  }

  assert {
    condition     = azurerm_application_gateway.main.firewall_policy_id == run.setup.firewall_policy_id
    error_message = "The Application Gateway Firewall Policy ID is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.sku[0].name == var.sku_name
    error_message = "The sku type of Application Gateway is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.sku[0].capacity == null
    error_message = "The capacity of Application Gateway is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.enable_http2 == var.enable_http2
    error_message = "The HTTP/2 setting of Application Gateway is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.gateway_ip_configuration[0].subnet_id == run.setup.subnet_id
    error_message = "The Application Gateway subnet ID is not as expected."
  }

  #region Backend Address Pools

  assert {
    condition     = length(azurerm_application_gateway.main.backend_address_pool) == length(var.backend_address_pools)
    error_message = "The number of Backend Address Pools is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[0].name == var.backend_address_pools[0].name
    error_message = "The name of the first Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[0].fqdns == null
    error_message = "The fqdns of the first Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[0].ip_addresses == null
    error_message = "The ip_addresses of the first Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[1].name == var.backend_address_pools[1].name
    error_message = "The name of the second Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[1].fqdns == var.backend_address_pools[1].fqdns
    error_message = "The fqdns of the second Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[1].ip_addresses == null
    error_message = "The ip_addresses of the second Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[2].name == var.backend_address_pools[2].name
    error_message = "The name of the third Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[2].fqdns == null
    error_message = "The fqdns of the third Backend Address Pool is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_address_pool[2].ip_addresses == var.backend_address_pools[2].ip_addresses
    error_message = "The ip_addresses of the third Backend Address Pool is not as expected."
  }
}

# run "apply" {
#   command = apply

#   variables {
#     name                = run.setup.workspace_id
#     resource_group_name = run.setup.resource_group_name
#     location            = run.setup.resource_group_location
#     tags                = run.setup.resource_group_tags
#     firewall_policy_id  = run.setup.firewall_policy_id
#     subnet_id           = run.setup.subnet_id
#     frontend_ip_configuration = {
#       public_ip_address_id = run.setup.public_ip_id
#     }
#   }

#   assert {
#     condition     = azurerm_application_gateway.main.id == "${run.setup.resource_group_id}/providers/Microsoft.Network/applicationGateways/${run.setup.workspace_id}"
#     error_message = "The Application Gateway ID is not as expected."
#   }

#   assert {
#     condition     = output.id == azurerm_application_gateway.main.id
#     error_message = "The Application Gateway ID output is not as expected."
#   }

#   assert {
#     condition     = output.name == azurerm_application_gateway.main.name
#     error_message = "The Application Gateway name output is not as expected."
#   }

#   assert {
#     condition     = output.resource_group_name == azurerm_application_gateway.main.resource_group_name
#     error_message = "The Application Gateway resource group output is not as expected."
#   }

#   assert {
#     condition     = output.location == azurerm_application_gateway.main.location
#     error_message = "The Application Gateway location output is not as expected."
#   }

#   assert {
#     condition     = output.tags == azurerm_application_gateway.main.tags
#     error_message = "The Application Gateway tags output is not as expected."
#   }
# }
