locals {
  waf_configuration_enabled     = lookup(var.waf_configuration, "enabled", false) == "true"
  private_ip_address            = lookup(var.frontend_ip_configuration, "private_ip_address", null) != null
  public_ip_address_id          = lookup(var.frontend_ip_configuration, "public_ip_address_id", null) != null
  private_ip_address_allocation = lookup(var.frontend_ip_configuration, "private_ip_address_allocation", null) != null
}
