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

variable "zones" {
  type        = list(number)
  default     = []
  description = "A list of availability zones to use for the Application Gateway. Possible values are `1`, `2` and `3`."

  validation {
    condition     = length(var.zones) == length(distinct(var.zones))
    error_message = "The zones must be unique."
  }

  validation {
    condition     = alltrue([for z in var.zones : z >= 1 && z <= 3])
    error_message = "The zones must be between 1 and 3."
  }
}

variable "sku_name" {
  type        = string
  description = "The SKU of the Application Gateway. Possible values are `Standard_v2` and `WAF_v2`."

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "The sku must be either Standard_v2 or WAF_v2."
  }
}

variable "enable_http2" {
  type        = bool
  default     = false
  description = "Enables HTTP/2 for the Application Gateway."
}

variable "firewall_policy_id" {
  type        = string
  default     = null
  description = "The ID of the Firewall Policy to associate with the Application Gateway."

  validation {
    condition     = var.sku_name == "WAF_v2" ? var.firewall_policy_id != null : true
    error_message = "The firewall_policy_id is required when the sku is WAF_v2."
  }

  validation {
    condition     = var.sku_name != "WAF_v2" ? var.firewall_policy_id == null : true
    error_message = "The firewall_policy_id is not allowed when the sku is Standard_v2."
  }
}

variable "capacity" {
  type        = number
  default     = null
  description = "The capacity (number of instances) of the Application Gateway. Possible values are between `1` and `125`."

  validation {
    condition     = var.capacity != null ? var.capacity >= 1 && var.capacity <= 125 : true
    error_message = "The max_capacity must be between 1 and 125."
  }
}

variable "autoscale_configuration" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "A mapping with the autoscale configuration of the application gateway."

  validation {
    condition     = var.autoscale_configuration != null ? var.autoscale_configuration.min_capacity >= 0 && var.autoscale_configuration.min_capacity <= 100 : true
    error_message = "The min_capacity must be between 0 and 100."
  }

  validation {
    condition     = var.autoscale_configuration != null ? var.autoscale_configuration.max_capacity >= 2 && var.autoscale_configuration.max_capacity <= 125 : true
    error_message = "The max_capacity must be between 2 and 125."
  }
}

variable "identity_id" {
  type        = string
  default     = null
  description = "The ID of the Managed Identity to associate with the Application Gateway."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the Application Gateway should be connected to."
}

variable "frontend_ip_configuration" {
  type = object({
    subnet_id                     = optional(string)
    public_ip_address_id          = string
    private_ip_address_allocation = optional(string)
    private_ip_address            = optional(string)
  })
  description = "A mapping the front ip configuration."
}

variable "backend_address_pools" {
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  description = "List of objects that represent the configuration of each backend address pool."

  validation {
    condition     = alltrue([for pools in var.backend_address_pools : alltrue([for ip in pools.ip_addresses : can(cidrnetmask("${ip}/32"))]) if pools.ip_addresses != null])
    error_message = "All IP addresses in the backend address pool must be formatted according to the CIDR standard without a mask."
  }
}

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
