# Azure Application Gateway - Terraform Module

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blueviolet.svg)](https://registry.terraform.io/modules/aztfm/application-gateway/azurerm/)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/aztfm/terraform-azurerm-application-gateway)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/aztfm/terraform-azurerm-application-gateway?quickstart=1)

## :gear: Version compatibility

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 2.x.x       | >= 1.9.x          | >= 3.40.0       |
| >= 1.x.x       | >= 0.13.x         | >= 2.0.0        |

## :memo: Usage

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "resource-group"
  location = "Spain Central"
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "snet" {
  name                 = "virtual-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

module "application_gateway_firewall_policy" {
  source              = "aztfm/application-gateway-firewall-policy/azurerm"
  version             = ">=1.0.0"
  name                = "application-gateway-firewall-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  managed_rule_sets = [{
    type    = "OWASP"
    version = "3.2"
    }, {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }]
}

module "application_gateway" {
  source              = "aztfm/application-gateway/azurerm"
  version             = ">=2.0.0"
  name                = "application-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "WAF_v2"
  firewall_policy_id  = module.application_gateway_firewall_policy.id
  capacity            = 1
  subnet_id           = azurerm_subnet.snet.id
  frontend_ip_configuration = {
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  backend_address_pools = [{
    name         = "backend-address-pool",
    ip_addresses = ["10.0.0.4","10.0.0.5"]
  }]
  http_listeners        = [{
    name                      = "http-listener"
    frontend_ip_configuration = "Public"
    protocol                  = "Http"
    port                      = 80
  }]
  backend_http_settings = [{
    name     = "backend-http-setting-1"
    protocol = "Http"
    port     = 80
  }]
  request_routing_rules = [{
    name                       = "request-routing-rule"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-setting"
  }]
}
```

<!-- BEGIN_TF_DOCS -->
## :arrow_forward: Parameters

The following parameters are supported:

| Name | Description | Type | Default | Required |
| ---- | ----------- | :--: | :-----: | :------: |
|name|The name of the Application Gateway.|`string`|n/a|yes|
|resource\_group\_name|The name of the resource group in which to create the Application Gateway.|`string`|n/a|yes|
|location|The location/region where the Application Gateway is created.|`string`|n/a|yes|
|tags|A mapping of tags to assign to the resource.|`map(string)`|`{}`|no|
|zones|A list of availability zones to use for the Application Gateway. Possible values are `1`, `2` and `3`.|`list(number)`|`[]`|no|
|sku\_name|The SKU of the Application Gateway. Possible values are `Standard_v2` and `WAF_v2`.|`string`|n/a|yes|
|enable\_http2|Enables HTTP/2 for the Application Gateway.|`bool`|`false`|no|
|firewall\_policy\_id|The ID of the Firewall Policy to associate with the Application Gateway.|`string`|`null`|no|
|capacity|The capacity (number of instances) of the Application Gateway. Possible values are between `1` and `125`.|`number`|`null`|no|
|autoscale\_configuration|A mapping with the autoscale configuration of the Application Gateway.|`object({})`|`null`|no|
|identity\_id|The ID of the Managed Identity to associate with the Application Gateway.|`string`|`null`|no|
|subnet\_id|The ID of the Subnet which the Application Gateway should be connected to.|`string`|n/a|yes|
|frontend\_ip\_configuration|A mapping with the frontend ip configuration of the Application Gateway.|`object({})`|n/a|yes|
|backend\_address\_pools|List of objects that represent the configuration of each backend address pool.|`list(object({}))`|n/a|yes|
|ssl\_certificates|List of objects that represent the configuration of each ssl certificate.|`list(object({}))`|`[]`|no|
|http\_listeners|List of objects that represent the configuration of each http listener.|`list(object({}))`|n/a|yes|
|probes|List of objects that represent the configuration of each probe.|`list(object({}))`|`[]`|no|
|backend\_http\_settings|List of objects that represent the configuration of each backend http settings.|`list(object({}))`|n/a|yes|
|request\_routing\_rules|List of objects that represent the configuration of each backend request routing rule.|`list(object({}))`|n/a|yes|

The `autoscale_configuration` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|min\_capacity|Minimum capacity for autoscaling. Accepted values are in the range `0` to `100`.|`number`|n/a|yes|
|max\_capacity|Maximum capacity for autoscaling. Accepted values are in the range `2` to `125`.|`number`|n/a|yes|

The `frontend_ip_configuration` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|public\_ip\_address\_id|The ID of a Public IP Address which the Application Gateway should use.|`string`|`null`|no|
|subnet\_id|The ID of the Subnet in which the Application Gateway should be deployed.|`string`|`null`|yes|
|private\_ip\_address|The Private IP Address to use for the Application Gateway.|`string`|`null`|no|

The `backend_address_pools` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The name of the Backend Address Pool.|`string`|n/a|yes|
|fqdns|A list of FQDNs which should be part of the Backend Address Pool.|`list(string)`|`null`|no|
|private\_ip\_address|A list of IP Addresses which should be part of the Backend Address Pool.|`list(string)`|`null`|no|

The `ssl_certificates` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of the SSL certificate that is unique within this Application Gateway.|`string`|n/a|yes|
|data|PFX certificate. Required if `key_vault_secret_id` is not set.|`string`|`null`|no|
|password|Password for the pfx file specified in data. Required if `data` is set.|`string`|`null`|no|
|key\_vault\_secret\_id|Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure Key Vault. You need to enable soft delete for Key Vault to use this feature. Required if `data` is not set.|`string`|`null`|no|

The `http_listeners` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of the HTTP Listener.|`string`|n/a|yes|
|frontend\_ip\_configuration|The frontend ip configuration to use for this HTTP Listener. Possible values are `Public` and `Private`.|`string`|n/a|yes|
|port|The port used for this HTTP Listener.|`number`|n/a|yes|
|protocol|The Protocol to use for this HTTP Listener. Possible values are `Http` and `Https`.|`string`|n/a|yes|
|host\_name|The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to Multi site.|`string`|`null`|no|
|ssl\_certificate\_name|The name of the associated SSL Certificate which should be used for this HTTP Listener.|`string`|`null`|no|

The `probes` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of the Probe.|`string`|n/a|yes|
|host|The Hostname used for this Probe. If the Application Gateway is configured for a single site, by default the Host name should be specified as `127.0.0.1`, unless otherwise configured in custom probe. Cannot be set if `pick_host_name_from_backend_http_settings` is set to `true`.|`string`|`null`|no|
|protocol|The Protocol used for this Probe. Possible values are `Http` and `Https`.|`string`|n/a|yes|
|path|The Path used for this Probe.|`string`|`/`|no|
|interval|The Interval between two consecutive probes in seconds. Possible values range from `1` second to a maximum of `86400` seconds.|`number`|`30`|no|
|timeout|The Timeout used for this Probe, which indicates when a probe becomes unhealthy. Possible values range from `1` second to a maximum of `86400` seconds.|`number`|`30`|no|
|unhealthy\_threshold|The Unhealthy Threshold for this Probe, which indicates the amount of retries which should be attempted before a node is deemed unhealthy. Possible values are from `1` to `20`.|`number`|`3`|no|

The `backend_http_settings` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The name of the Backend HTTP Settings Collection.|`string`|n/a|yes|
|protocol|The Protocol which should be used. Possible values are `Http` and `Https`.|`string`|n/a|yes|
|port|The port which should be used for this Backend HTTP Settings Collection.|`string`|n/a|yes|
|cookie\_based\_affinity|The cookie based affinity configuration. Possible values are `Disabled` and `Enabled`.|`string`|`Disabled`|no|
|request\_timeout|The request timeout in seconds, which must be between `1` and `86400` seconds.|`number`|`30`|no|
|host\_name|Host header to be sent to the backend servers. Cannot be set if `pick_host_name_from_backend_address` is set to `true`.|`string`|`null`|no|
|probe\_name|The name of an associated HTTP Probe.|`string`|`null`|no|

The `request_routing_rules` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of this Request Routing Rule.|`string`|n/a|yes|
|priority|The Priority of this Request Routing Rule.|`number`|n/a|yes|
|http\_listener\_name|The Name of the HTTP Listener which should be used for this Routing Rule.|`string`|n/a|yes|
|backend\_address\_pool\_name|The Name of the Backend Address Pool which should be used for this Routing Rule.|`string`|n/a|yes|
|backend\_http\_settings\_name|The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule.|`string`|n/a|yes|

## :arrow_backward: Outputs

The following outputs are exported:

| Name | Description | Sensitive |
| ---- | ------------| :-------: |
|id|The application gateway configuration ID.|no|
|name|The name of the application gateway.|no|
|resource_group_name|The name of the resource group in which to create the application gateway.|no|
|location|The location/region where the application gateway is created.|no|
|tags|The tags assigned to the resource.|no|
|backend_address_pools|Blocks containing configuration of each backend address pool.|no|
|ssl_certificates|Blocks containing configuration of each ssl certificate.|no|
|http_listeners|Blocks containing configuration of each http listener.|no|
|backend_http_settings|Blocks containing configuration of each backend http settings.|no|
|request_routing_rules|Blocks containing configuration of each request routing rule.|no|
<!-- END_TF_DOCS -->
