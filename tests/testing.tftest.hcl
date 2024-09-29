provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
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
  default_ssl_policy = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }
  ssl_profiles = [{
    name        = "ssl-profile-1"
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
    }, {
    name                 = "ssl-profile-2"
    policy_type          = "CustomV2"
    min_protocol_version = "TLSv1_2"
    cipher_suites = [
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
    ]
  }]
  backend_address_pools = [{
    name = "backend-address-pool-1"
    }, {
    name  = "backend-address-pool-2"
    fqdns = ["domini1.com", "domini2.com"]
    }, {
    name         = "backend-address-pool-3"
    ip_addresses = ["10.0.10.1", "192.16.0.4"]
  }]
  probes = [{
    name     = "probe-1"
    protocol = "Http"
    }, {
    name                = "probe-2"
    host                = "domain.com"
    protocol            = "Https"
    path                = "/health"
    interval            = 60
    timeout             = 120
    unhealthy_threshold = 9
  }]
  backend_http_settings = [{
    name     = "backend-http-setting-1"
    protocol = "Http"
    port     = 80
    }, {
    name                  = "backend-http-setting-2"
    protocol              = "Https"
    port                  = 443
    cookie_based_affinity = "Enabled"
    request_timeout       = 120
    host_name             = "domain.com"
    probe_name            = "probe-2"
  }]
  request_routing_rules = [{
    name                       = "request-routing-rule-1"
    priority                   = 100
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-address-pool-1"
    backend_http_settings_name = "backend-http-setting-1"
    }, {
    name                       = "request-routing-rule-2"
    priority                   = 200
    http_listener_name         = "http-listener-2"
    backend_address_pool_name  = "backend-address-pool-2"
    backend_http_settings_name = "backend-http-setting-2"
  }]
}

run "plan" {
  command = plan

  variables {
    name                = run.setup.workspace_id
    resource_group_name = run.setup.resource_group_name
    location            = run.setup.resource_group_location
    tags                = run.setup.resource_group_tags
    firewall_policy_id  = run.setup.firewall_policy_id
    identity_id         = run.setup.managed_identity_id
    subnet_id           = run.setup.subnet_id
    frontend_ip_configuration = {
      public_ip_address_id = run.setup.public_ip_id
      subnet_id            = run.setup.subnet_id
      private_ip_address   = cidrhost(run.setup.subnet_address_prefix, 10)
    }
    ssl_certificates = [{
      name                = "${run.setup.workspace_id}1"
      key_vault_secret_id = run.setup.key_vault_certificate_secret_id
      }, {
      name     = "${run.setup.workspace_id}2"
      data     = run.setup.certificate_data
      password = run.setup.workspace_id
    }]
    http_listeners = [{
      name                      = "http-listener-1"
      frontend_ip_configuration = "Public"
      port                      = 80
      protocol                  = "Http"
      }, {
      name                      = "http-listener-2"
      frontend_ip_configuration = "Private"
      port                      = 8080
      protocol                  = "Http"
      }, {
      name                      = "http-listener-3"
      frontend_ip_configuration = "Public"
      port                      = 1433
      protocol                  = "Http"
      }, {
      name                      = "http-listener-4"
      frontend_ip_configuration = "Private"
      port                      = 445
      protocol                  = "Https"
      ssl_certificate_name      = "${run.setup.workspace_id}1"
    }]
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
    condition     = azurerm_application_gateway.main.gateway_ip_configuration[0].name == "GatewayIpConfiguration"
    error_message = "The Application Gateway subnet ID is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.gateway_ip_configuration[0].subnet_id == run.setup.subnet_id
    error_message = "The Application Gateway subnet ID is not as expected."
  }

  #region Backend Address Pools

  assert {
    condition     = { for backend in azurerm_application_gateway.main.backend_address_pool : backend.name => backend }["backend-address-pool-1"].name == var.backend_address_pools[0].name
    error_message = "The name of the first Backend Address Pool is not as expected."
  }

  assert {
    condition     = { for backend in azurerm_application_gateway.main.backend_address_pool : backend.name => backend }["backend-address-pool-2"].name == var.backend_address_pools[1].name
    error_message = "The name of the second Backend Address Pool is not as expected."
  }

  assert {
    condition     = { for backend in azurerm_application_gateway.main.backend_address_pool : backend.name => backend }["backend-address-pool-2"].fqdns == toset(var.backend_address_pools[1].fqdns)
    error_message = "The fqdns of the second Backend Address Pool is not as expected."
  }

  assert {
    condition     = { for backend in azurerm_application_gateway.main.backend_address_pool : backend.name => backend }["backend-address-pool-3"].name == var.backend_address_pools[2].name
    error_message = "The name of the third Backend Address Pool is not as expected."
  }

  assert {
    condition     = { for backend in azurerm_application_gateway.main.backend_address_pool : backend.name => backend }["backend-address-pool-3"].ip_addresses == toset(var.backend_address_pools[2].ip_addresses)
    error_message = "The ip_addresses of the third Backend Address Pool is not as expected."
  }

  #region Frontend IP Configuration

  assert {
    condition     = length(azurerm_application_gateway.main.frontend_ip_configuration) == 2
    error_message = "The number of Frontend IP Configurations is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[0].name == "FrontendPublicIpConfiguration"
    error_message = "The name of the first Frontend IP Configuration is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[1].name == "FrontendPrivateIpConfiguration"
    error_message = "The name of the second Frontend IP Configuration is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[1].private_ip_address_allocation == "Static"
    error_message = "The name of the second Frontend IP Configuration is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[1].private_ip_address == cidrhost(run.setup.subnet_address_prefix, 10)
    error_message = "The name of the second Frontend IP Configuration is not as expected."
  }

  #region Managed Identity

  assert {
    condition     = length(azurerm_application_gateway.main.identity[0].identity_ids) == 1
    error_message = "The number of Managed Identities is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.identity[0].type == "UserAssigned"
    error_message = "The Managed Identity type is not as expected."
  }

  assert {
    condition     = tolist(azurerm_application_gateway.main.identity[0].identity_ids) == tolist([run.setup.managed_identity_id])
    error_message = "The Managed Identity ID is not as expected."
  }

  #region HTTP Listeners

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-1"].name == var.http_listeners[0].name
    error_message = "The name of the first HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-1"].frontend_ip_configuration_name == "FrontendPublicIpConfiguration"
    error_message = "The frontend_ip_configuration of the first HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-1"].frontend_port_name == tostring(var.http_listeners[0].port)
    error_message = "The port of the first HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-1"].protocol == var.http_listeners[0].protocol
    error_message = "The protocol of the first HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-2"].name == var.http_listeners[1].name
    error_message = "The name of the second HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-2"].frontend_ip_configuration_name == "FrontendPrivateIpConfiguration"
    error_message = "The frontend_ip_configuration of the second HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-2"].frontend_port_name == tostring(var.http_listeners[1].port)
    error_message = "The port of the second HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-2"].protocol == var.http_listeners[1].protocol
    error_message = "The protocol of the second HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-3"].name == var.http_listeners[2].name
    error_message = "The name of the third HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-3"].frontend_ip_configuration_name == "FrontendPublicIpConfiguration"
    error_message = "The frontend_ip_configuration of the third HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-3"].frontend_port_name == tostring(var.http_listeners[2].port)
    error_message = "The port of the third HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-3"].protocol == var.http_listeners[2].protocol
    error_message = "The protocol of the third HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-4"].name == var.http_listeners[3].name
    error_message = "The name of the fourth HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-4"].frontend_ip_configuration_name == "FrontendPrivateIpConfiguration"
    error_message = "The frontend_ip_configuration of the fourth HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-4"].frontend_port_name == tostring(var.http_listeners[3].port)
    error_message = "The port of the fourth HTTP Listener is not as expected."
  }

  assert {
    condition     = { for listener in azurerm_application_gateway.main.http_listener : listener.name => listener }["http-listener-4"].protocol == var.http_listeners[3].protocol
    error_message = "The protocol of the fourth HTTP Listener is not as expected."
  }

  #region Default SSL Policy

  assert {
    condition     = azurerm_application_gateway.main.ssl_policy[0].policy_type == var.default_ssl_policy.policy_type
    error_message = "The policy_type of the Default SSL Policy is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.ssl_policy[0].policy_name == var.default_ssl_policy.policy_name
    error_message = "The policy_name of the Default SSL Policy is not as expected."
  }

  #region SSL Profiles

  assert {
    condition     = length(azurerm_application_gateway.main.ssl_profile) == 2
    error_message = "The number of SSL Profiles is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-1"].name == var.ssl_profile[0].name
    error_message = "The name of the first SSL Profile is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-1"].policy_type == var.ssl_profile[0].policy_type
    error_message = "The policy_type of the first SSL Profile is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-1"].policy_name == var.ssl_profile[0].policy_name
    error_message = "The policy_name of the first SSL Profile is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-2"].name == var.ssl_profile[1].name
    error_message = "The name of the second SSL Profile is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-2"].policy_type == var.ssl_profile[1].policy_type
    error_message = "The policy_type of the second SSL Profile is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-2"].min_protocol_version == var.ssl_profile[1].min_protocol_version
    error_message = "The min_protocol_version of the second SSL Profile is not as expected."
  }

  assert {
    condition     = { for profile in azurerm_application_gateway.main.ssl_profile : profile.name => profile }["ssl-profile-2"].cipher_suites == toset(var.ssl_profile[1].cipher_suites)
    error_message = "The cipher_suites of the second SSL Profile is not as expected."
  }

  #region SSL Certificates

  assert {
    condition     = { for cert in azurerm_application_gateway.main.ssl_certificate : cert.name => cert }["${run.setup.workspace_id}1"].name == var.ssl_certificates[0].name
    error_message = "The name of the first SSL Certificate is not as expected."
  }

  assert {
    condition     = { for cert in azurerm_application_gateway.main.ssl_certificate : cert.name => cert }["${run.setup.workspace_id}1"].key_vault_secret_id == var.ssl_certificates[0].key_vault_secret_id
    error_message = "The key_vault_secret_id of the first SSL Certificate is not as expected."
  }

  assert {
    condition     = { for cert in azurerm_application_gateway.main.ssl_certificate : cert.name => cert }["${run.setup.workspace_id}2"].name == var.ssl_certificates[1].name
    error_message = "The name of the second SSL Certificate is not as expected."
  }

  assert {
    condition     = { for cert in azurerm_application_gateway.main.ssl_certificate : cert.name => cert }["${run.setup.workspace_id}2"].data == var.ssl_certificates[1].data
    error_message = "The data of the second SSL Certificate is not as expected."
  }

  assert {
    condition     = { for cert in azurerm_application_gateway.main.ssl_certificate : cert.name => cert }["${run.setup.workspace_id}2"].password == var.ssl_certificates[1].password
    error_message = "The password of the second SSL Certificate is not as expected."
  }

  #region Health Probes

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].name == var.probes[0].name
    error_message = "The name of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].protocol == var.probes[0].protocol
    error_message = "The protocol of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].path == "/"
    error_message = "The path of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].pick_host_name_from_backend_http_settings == true
    error_message = "The pick_host_name_from_backend_http_settings of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].interval == 30
    error_message = "The interval of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].timeout == 30
    error_message = "The timeout of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-1"].unhealthy_threshold == 3
    error_message = "The unhealthy_threshold of the first Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].name == var.probes[1].name
    error_message = "The name of the second Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].host == var.probes[1].host
    error_message = "The host of the second Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].protocol == var.probes[1].protocol
    error_message = "The protocol of the second Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].path == var.probes[1].path
    error_message = "The path of the second Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].interval == var.probes[1].interval
    error_message = "The interval of the second Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].timeout == var.probes[1].timeout
    error_message = "The timeout of the second Health Probe is not as expected."
  }

  assert {
    condition     = { for probe in azurerm_application_gateway.main.probe : probe.name => probe }["probe-2"].unhealthy_threshold == var.probes[1].unhealthy_threshold
    error_message = "The unhealthy_threshold of the second Health Probe is not as expected."
  }

  #region Backend HTTP Settings

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-1"].name == var.backend_http_settings[0].name
    error_message = "The name of the first Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-1"].protocol == var.backend_http_settings[0].protocol
    error_message = "The protocol of the first Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-1"].port == var.backend_http_settings[0].port
    error_message = "The port of the first Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-1"].cookie_based_affinity == var.backend_http_settings[0].cookie_based_affinity
    error_message = "The cookie_based_affinity of the first Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].name == var.backend_http_settings[1].name
    error_message = "The name of the second Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].protocol == var.backend_http_settings[1].protocol
    error_message = "The protocol of the second Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].port == var.backend_http_settings[1].port
    error_message = "The port of the second Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].cookie_based_affinity == var.backend_http_settings[1].cookie_based_affinity
    error_message = "The cookie_based_affinity of the second Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].request_timeout == var.backend_http_settings[1].request_timeout
    error_message = "The request_timeout of the second Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].host_name == var.backend_http_settings[1].host_name
    error_message = "The host_name of the second Backend HTTP Settings is not as expected."
  }

  assert {
    condition     = { for settings in azurerm_application_gateway.main.backend_http_settings : settings.name => settings }["backend-http-setting-2"].probe_name == var.backend_http_settings[1].probe_name
    error_message = "The probe_name of the second Backend HTTP Settings is not as expected."
  }

  #region Request Routing Rules

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-1"].name == var.request_routing_rules[0].name
    error_message = "The name of the first Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-1"].priority == var.request_routing_rules[0].priority
    error_message = "The priority of the first Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-1"].http_listener_name == var.request_routing_rules[0].http_listener_name
    error_message = "The http_listener_name of the first Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-1"].backend_address_pool_name == var.request_routing_rules[0].backend_address_pool_name
    error_message = "The backend_address_pool_name of the first Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-1"].backend_http_settings_name == var.request_routing_rules[0].backend_http_settings_name
    error_message = "The backend_http_settings_name of the first Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-2"].name == var.request_routing_rules[1].name
    error_message = "The name of the second Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-2"].priority == var.request_routing_rules[1].priority
    error_message = "The priority of the second Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-2"].http_listener_name == var.request_routing_rules[1].http_listener_name
    error_message = "The http_listener_name of the second Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-2"].backend_address_pool_name == var.request_routing_rules[1].backend_address_pool_name
    error_message = "The backend_address_pool_name of the second Request Routing Rule is not as expected."
  }

  assert {
    condition     = { for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule }["request-routing-rule-2"].backend_http_settings_name == var.request_routing_rules[1].backend_http_settings_name
    error_message = "The backend_http_settings_name of the second Request Routing Rule is not as expected."
  }
}

run "apply" {
  command = apply

  variables {
    name                = run.setup.workspace_id
    resource_group_name = run.setup.resource_group_name
    location            = run.setup.resource_group_location
    tags                = run.setup.resource_group_tags
    firewall_policy_id  = run.setup.firewall_policy_id
    identity_id         = run.setup.managed_identity_id
    subnet_id           = run.setup.subnet_id
    frontend_ip_configuration = {
      subnet_id            = run.setup.subnet_id
      public_ip_address_id = run.setup.public_ip_id
      private_ip_address   = cidrhost(run.setup.subnet_address_prefix, 10)
    }
    ssl_certificates = [{
      name                = "${run.setup.workspace_id}1"
      key_vault_secret_id = run.setup.key_vault_certificate_secret_id
      }, {
      name     = "${run.setup.workspace_id}2"
      data     = run.setup.certificate_data
      password = run.setup.workspace_id
    }]
    http_listeners = [{
      name                      = "http-listener-1"
      frontend_ip_configuration = "Public"
      port                      = 80
      protocol                  = "Http"
      }, {
      name                      = "http-listener-2"
      frontend_ip_configuration = "Private"
      port                      = 8080
      protocol                  = "Http"
      }, {
      name                      = "http-listener-3"
      frontend_ip_configuration = "Public"
      port                      = 1433
      protocol                  = "Http"
      }, {
      name                      = "http-listener-4"
      frontend_ip_configuration = "Private"
      port                      = 445
      protocol                  = "Https"
      ssl_certificate_name      = "${run.setup.workspace_id}1"
    }]
  }

  assert {
    condition     = azurerm_application_gateway.main.id == "${run.setup.resource_group_id}/providers/Microsoft.Network/applicationGateways/${run.setup.workspace_id}"
    error_message = "The Application Gateway ID is not as expected."
  }

  assert {
    condition     = output.id == azurerm_application_gateway.main.id
    error_message = "The Application Gateway ID output is not as expected."
  }

  assert {
    condition     = output.name == azurerm_application_gateway.main.name
    error_message = "The Application Gateway name output is not as expected."
  }

  assert {
    condition     = output.resource_group_name == azurerm_application_gateway.main.resource_group_name
    error_message = "The Application Gateway resource group output is not as expected."
  }

  assert {
    condition     = output.location == azurerm_application_gateway.main.location
    error_message = "The Application Gateway location output is not as expected."
  }

  assert {
    condition     = output.tags == azurerm_application_gateway.main.tags
    error_message = "The Application Gateway tags output is not as expected."
  }

  #region Backend Address Pools

  assert {
    condition     = length(azurerm_application_gateway.main.backend_address_pool) == length(var.backend_address_pools)
    error_message = "The number of Backend Address Pools is not as expected."
  }

  #region Frontend IP Configuration

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[0].public_ip_address_id == run.setup.public_ip_id
    error_message = "The public_ip_address_id of the first Frontend IP Configuration is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[1].subnet_id == run.setup.subnet_id
    error_message = "The subnet_id of the second Frontend IP Configuration is not as expected."
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_ip_configuration[1].private_ip_address == cidrhost(run.setup.subnet_address_prefix, 10)
    error_message = "The private_ip_address of the second Frontend IP Configuration is not as expected."
  }
}
