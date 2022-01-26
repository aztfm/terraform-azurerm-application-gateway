resource "azurerm_application_gateway" "appgw" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku.size
    tier     = var.sku.tier
    capacity = var.autoscale_configuration == null ? var.sku.capacity : null
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration == null ? [] : ["autoscale_configuration"]
    content {
      min_capacity = var.autoscale_configuration.min_capacity
      max_capacity = var.autoscale_configuration.max_capacity
    }
  }

  gateway_ip_configuration {
    name      = "${var.name}-configuration"
    subnet_id = var.subnet_id
  }

  dynamic "frontend_ip_configuration" {
    for_each = local.public_ip_address_id ? [""] : []
    content {
      name                 = "Public-frontend-ip-configuration"
      public_ip_address_id = var.frontend_ip_configuration.public_ip_address_id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = local.private_ip_address || local.private_ip_address_allocation ? [""] : []
    content {
      name                          = "Private-frontend-ip-configuration"
      subnet_id                     = var.subnet_id
      private_ip_address            = var.frontend_ip_configuration.private_ip_address
      private_ip_address_allocation = var.frontend_ip_configuration.private_ip_address_allocation
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", "") == "" ? null : split(",", backend_address_pool.value.ip_addresses)
    }
  }

  frontend_port {
    name = "80"
    port = 80
  }

  frontend_port {
    name = "443"
    port = 443
  }

  dynamic "identity" {
    for_each = var.identity_id != null ? [""] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.identity_id]
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = lookup(ssl_certificate.value, "data", null)
      password            = lookup(ssl_certificate.value, "password", null)
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "${http_listener.value.frontend_ip_configuration}-frontend-ip-configuration"
      frontend_port_name             = http_listener.value.port
      protocol                       = http_listener.value.protocol
      host_name                      = lookup(http_listener.value, "host_name", null)
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      name                = probe.value.name
      host                = lookup(probe.value, "host", null)
      protocol            = probe.value.protocol
      path                = probe.value.path
      interval            = probe.value.interval
      timeout             = probe.value.timeout
      unhealthy_threshold = probe.value.unhealthy_threshold
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      cookie_based_affinity = "Disabled"
      name                  = backend_http_settings.value.name
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = backend_http_settings.value.request_timeout
      host_name             = lookup(backend_http_settings.value, "host_name", null)
      probe_name            = lookup(backend_http_settings.value, "probe_name", null)
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }

  tags = var.tags
}
