resource "azurerm_application_gateway" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

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

  gateway_ip_configuration {
    name      = "appgateway-ip-configuration" # TODO: Modify this name
    subnet_id = var.subnet_id
  }

  dynamic "waf_configuration" {
    for_each = local.waf_configuration_enabled ? [""] : []

    content {
      enabled          = var.waf_configuration.enabled
      firewall_mode    = lookup(var.waf_configuration, "firewall_mode", "Detection")
      rule_set_version = lookup(var.waf_configuration, "rule_set_version", "3.0")
      # file_upload_limit_mb     = lookup(var.waf_configuration, "file_upload_limit_mb", 100)
      # request_body_check       = lookup(var.waf_configuration, "request_body_check", true)
      # max_request_body_size_kb = lookup(var.waf_configuration, "max_request_body_size_kb", 128)
    }
  }

  frontend_ip_configuration {
    name                          = "Public-frontend-ip-configuration" # TODO: Modify this name
    subnet_id                     = var.frontend_ip_configuration.subnet_id
    private_ip_address            = var.frontend_ip_configuration.private_ip_address
    private_ip_address_allocation = var.frontend_ip_configuration.private_ip_address_allocation
    public_ip_address_id          = var.frontend_ip_configuration.public_ip_address_id
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
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  frontend_port {
    name = "80" # TODO: Modify this name
    port = 80
  }

  frontend_port {
    name = "443" # TODO: Modify this name
    port = 443
  }

  dynamic "identity" {
    for_each = var.identity_ids != null ? [""] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates != null ? [""] : []

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
      frontend_ip_configuration_name = "${http_listener.value.frontend_ip_configuration}-frontend-ip-configuration" # TODO: Modify this name
      frontend_port_name             = http_listener.value.port
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
    }
  }

  dynamic "probe" {
    for_each = var.probes != null ? [""] : []

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
      host_name             = backend_http_settings.value.host_name
      probe_name            = backend_http_settings.value.probe_name
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
}
