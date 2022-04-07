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
variable "sku" {
  type        = map(string)
  description = "A mapping with the sku configuration of the application gateway."
  # sku = { tier = "", size = "", capacity = "" }
}
variable "autoscale_configuration" {
  type        = map(string)
  default     = {}
  description = ""
  # autoscale_configuration = { min_capacity = "", max_capacity = "" }
}
variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the Application Gateway should be connected to."
}
variable "waf_configuration" {
  type        = map(string)
  default     = {}
  description = ""
  # waf_configuration = { enabled = "", firewall_mode = "", rule_set_version = ""}
}
variable "disabled_rule_group" {
  type        = set(object({ rule_group_name = string, rules = set(number) }))
  default     = []
  description = "Rule-groups to disable"
}
variable "frontend_ip_configuration" {
  type        = map(string)
  description = "A mapping the front ip configuration."
  # frontend_ip_configuration = { public_ip_address_id = "", private_ip_address = "", private_ip_address_allocation = "" }
}
variable "backend_address_pools" {
  type        = list(map(string))
  description = "List of objects that represent the configuration of each backend address pool."
  # backend_address_pools = [{ name = "", ip_addresses = "" }]
}
variable "identity_id" {
  type        = string
  default     = null
  description = "Specifies a user managed identity id to be assigned to the Application Gateway."
}
variable "ssl_certificates" {
  type        = list(map(string))
  default     = []
  description = "List of objects that represent the configuration of each ssl certificate."
  # ssl_certificates = [{ name = "", data = "", password = "", key_vault_secret_id = "" }]
}
variable "http_listeners" {
  type        = list(map(string))
  description = "List of objects that represent the configuration of each http listener."
  # http_listeners = [{ name = "", frontend_ip_configuration = "", port = "", protocol = "", host_name = "", host_names = "hostname1,hostname2", ssl_certificate_name = "" }]
}
variable "probes" {
  type        = list(map(string))
  default     = []
  description = "List of objects that represent the configuration of each probe."
  # probes = [{ name = "", host = "", protocol = "", path = "", interval = "", timeout = "", unhealthy_threshold = "" }]
}
variable "backend_http_settings" {
  type        = list(map(string))
  description = "List of objects that represent the configuration of each backend http settings."
  # backend_http_settings = [{ name = "", port = "", protocol = "", request_timeout = "", host_name = "", probe_name = "" }]
}
variable "request_routing_rules" {
  type        = list(map(string))
  description = "List of objects that represent the configuration of each backend request routing rule."
  # request_routing_rules = [{ name = "", http_listener_name = "", backend_address_pool_name = "", backend_http_settings_name = "" }]
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}
variable "ssl_policy" {
  description = "(Optional) Application Gateway SSL configuration"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string)
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = null
}
variable "enable_http2" {
  description = "Enable HTTP2"
  default     = false
}
