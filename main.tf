resource "azurerm_application_gateway" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  zones               = var.zones
  enable_http2        = var.enable_http2
  firewall_policy_id  = var.firewall_policy_id

  sku {
    name     = var.sku_name
    tier     = var.sku_name
    capacity = var.capacity
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [""] : []

    content {
      min_capacity = var.autoscale_configuration.min_capacity
      max_capacity = var.autoscale_configuration.max_capacity
    }
  }

  dynamic "identity" {
    for_each = var.identity_id != null ? [""] : []

    content {
      type         = "UserAssigned"
      identity_ids = [var.identity_id]
    }
  }

  gateway_ip_configuration {
    name      = "GatewayIpConfiguration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "FrontendPublicIpConfiguration"
    public_ip_address_id = var.frontend_ip_configuration.public_ip_address_id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configuration.subnet_id != null ? [""] : []

    content {
      name                          = "FrontendPrivateIpConfiguration"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = var.subnet_id != null ? "Static" : null
      private_ip_address            = var.frontend_ip_configuration.private_ip_address
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools

    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "frontend_port" {
    for_each = [for port in distinct(var.http_listeners[*].port) : port]

    content {
      name = tostring(frontend_port.value)
      port = frontend_port.value
    }
  }

  dynamic "ssl_policy" {
    for_each = var.ssl_policies

    content {
      policy_type          = ssl_policy.value.policy_type
      policy_name          = ssl_policy.value.policy_name
      disabled_protocols   = ssl_policy.value.disabled_protocols
      min_protocol_version = ssl_policy.value.min_protocol_version
      cipher_suites        = ssl_policy.value.cipher_suites
    }
  }

  dynamic "ssl_certificate" {
    for_each = nonsensitive(var.ssl_certificates)

    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.data
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration == "Private" ? "FrontendPrivateIpConfiguration" : "FrontendPublicIpConfiguration"
      frontend_port_name             = http_listener.value.port
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
    }
  }

  dynamic "probe" {
    for_each = var.probes

    content {
      name                                      = probe.value.name
      host                                      = probe.value.host
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.host == null ? true : null
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content {
      name                                = backend_http_settings.value.name
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      request_timeout                     = backend_http_settings.value.request_timeout
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.host_name == null ? true : null
      probe_name                          = backend_http_settings.value.probe_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules

    content {
      name                       = request_routing_rule.value.name
      rule_type                  = "Basic"
      priority                   = request_routing_rule.value.priority
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }
}
