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
  default     = {}
  description = "A mapping of tags to assign to the resource."
}

variable "sku" {
  type = object({
    tier     = string
    size     = string
    capacity = number
  })
  description = "A mapping with the sku configuration of the application gateway."
}

# variable "autoscale_configuration" {
#   type = object({
#     min_capacity = number
#     max_capacity = number
#   })
#   default     = null
#   description = "A mapping with the autoscale configuration of the application gateway."
# }

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the Application Gateway should be connected to."
}

variable "waf_configuration" {
  type = object({
    enabled          = optional(bool, true)
    firewall_mode    = optional(string, "Prevention")
    rule_set_version = optional(string, "3.2")
  })
  default     = {}
  description = "A mapping with the waf configuration of the application gateway."
}

variable "frontend_ip_configuration" {
  type = object({
    public_ip_address_id          = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
  })
  description = "A mapping the front ip configuration."
}

variable "backend_address_pools" {
  type = list(object({
    name         = string
    ip_addresses = optional(list(string))
  }))
  description = "List of objects that represent the configuration of each backend address pool."
}

# variable "identity_id" {
#   type        = string
#   default     = null
#   description = "Specifies a user managed identity id to be assigned to the Application Gateway."
# }

# variable "ssl_certificates" {
#   type = list(object({
#     name                = string
#     data                = optional(string)
#     password            = optional(string)
#     key_vault_secret_id = optional(string)
#   }))
#   default     = []
#   sensitive   = true
#   description = "List of objects that represent the configuration of each ssl certificate."
# }

variable "http_listeners" {
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

# variable "probes" {
#   type = list(object({
#     name                = string
#     host                = optional(string)
#     protocol            = string
#     path                = string
#     interval            = number
#     timeout             = string
#     unhealthy_threshold = string
#   }))
#   default     = []
#   description = "List of objects that represent the configuration of each probe."
# }

variable "backend_http_settings" {
  type = list(object({
    name            = string
    port            = string
    protocol        = string
    request_timeout = number
    host_name       = optional(string)
    probe_name      = optional(string)
  }))
  description = "List of objects that represent the configuration of each backend http settings."
}

variable "request_routing_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
  description = "List of objects that represent the configuration of each backend request routing rule."
}
