variable "name" {
  type        = string
  description = "The name of the Application Gateway."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Application Gateway."
}

variable "location" {
  type        = string
  description = "The location/region where the Application Gateway is created."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A mapping of tags to assign to the resource."
}

variable "sku_name" {
  type        = string
  description = "The SKU to use for the Application Gateway."

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "The sku name must be either Standard_v2 or WAF_v2."
  }
}

variable "capacity" {
  type        = number
  default     = null
  description = "The number of instances to use for the Application Gateway."

  validation {
    condition     = var.capacity <= 125 && var.capacity >= 1
    error_message = "The capacity must be between 1 and 125."
  }

  validation {
    condition     = var.autoscale_configuration != null
    error_message = "The capacity shouldn't be set when autoscale_configuration is set."

  }
}

variable "autoscale_configuration" {
  type = object({
    min_capacity = string
    max_capacity = string
  })
  default     = null
  description = "The autoscale configuration for the Application Gateway."

  validation {
    condition     = var.autoscale_configuration.min_capacity <= 100 && var.capacity >= 0
    error_message = "The min_capacity must be between 0 and 100."
  }

  validation {
    condition     = var.autoscale_configuration.max_capacity <= 125 && var.capacity >= 2
    error_message = "The max_capacity must be between 2 and 125."
  }
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the Application Gateway should be connected to."
}

variable "waf_configuration" { # TODO: Add more properties or remove this block
  type = object({
    enabled          = bool
    firewall_mode    = string
    rule_set_version = string
  })
  default     = {}
  description = ""
  # waf_configuration = { enabled = "", firewall_mode = "", rule_set_version = ""}
}

variable "frontend_ip_configuration" { # TODO: add more validations
  type = object({
    name                          = string
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
    public_ip_address_id          = string
  })
  description = "A mapping the front ip configuration."

  validation {
    condition     = var.frontend_ip_configuration.private_ip_address_allocation == "Static" && var.frontend_ip_configuration.private_ip_address != null
    error_message = "The private_ip_address must be set when private_ip_address_allocation is Static."
  }
}

variable "backend_address_pools" { # TODO: Add more validations
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  description = "List of objects that represent the configuration of each backend address pool."
}

variable "identity_ids" {
  type        = list(string)
  default     = null
  description = "List of Managed Identity IDs to assign to the Application Gateway."
}

variable "ssl_certificates" { # TODO: Add more validations
  type = list(object({
    name                = string
    data                = string
    password            = string
    key_vault_secret_id = string
  }))
  default     = null
  description = "List of objects that represent the configuration of each ssl certificate."
}

variable "http_listeners" { # TODO: Add more validations
  type = list(object({
    name                      = string
    frontend_ip_configuration = string
    port                      = string
    protocol                  = string
    host_name                 = optional(string)
    ssl_certificate_name      = optional(string)
  }))
  description = "List of objects that represent the configuration of each http listener."
}

variable "probes" { # TODO: Add more validations
  type = list(object({
    name                = string
    host                = optional(string)
    protocol            = string
    path                = string
    interval            = string
    timeout             = string
    unhealthy_threshold = string
  }))
  default     = null
  description = "List of objects that represent the configuration of each probe."
}

variable "backend_http_settings" {
  type = list(object({ # TODO: Add more validations
    name            = string
    port            = string
    protocol        = string
    request_timeout = string
    host_name       = optional(string)
    probe_name      = optional(string)
  }))
  description = "List of objects that represent the configuration of each backend http settings."
}

variable "request_routing_rules" {
  type = list(object({ # TODO: Add more validations
    name                       = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
  description = "List of objects that represent the configuration of each backend request routing rule."
}
