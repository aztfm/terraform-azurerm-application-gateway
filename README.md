# Azure Application Gateway - Terraform Module

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blueviolet.svg)](https://registry.terraform.io/modules/aztfm/application-gateway/azurerm/)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/aztfm/terraform-azurerm-application-gateway)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/aztfm/terraform-azurerm-application-gateway?quickstart=1)

## Version compatibility

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 1.x.x       | >= 1.9.x          | >= 3.40.0       |
| >= 1.x.x       | >= 0.13.x         | >= 2.0.0        |

<!-- BEGIN_TF_DOCS -->
## Parameters

The following parameters are supported:

| Name | Description | Type | Default | Required |
| ---- | ----------- | :--: | :-----: | :------: |
|name|The name of the Application Gateway.|`string`|n/a|yes|
|resource\_group\_name|The name of the resource group in which to create the Application Gateway.|`string`|n/a|yes|
|location|The location/region where the Application Gateway is created.|`string`|n/a|yes|
|tags|A mapping of tags to assign to the resource.|`map(string)`|`{}`|no|
|firewall\_policy\_id|The ID of the Firewall Policy to associate with the Application Gateway.|`string`|n/a|yes|
|sku\_name|The SKU of the Application Gateway.|`string`|n/a|yes|
|capacity|The capacity (number of instances) of the Application Gateway.|`number`|`null`|no|
|autoscale\_configuration|A mapping with the autoscale configuration of the application gateway.|`object({})`|`null`|no|
|subnet\_id|The ID of the Subnet which the Application Gateway should be connected to.|`string`|n/a|yes|
|frontend\_ip\_configuration|A mapping the front ip configuration.|`object({})`|n/a|yes|
|backend\_address\_pools|List of objects that represent the configuration of each backend address pool.|`list(object({}))`|n/a|yes|
|http\_listeners|List of objects that represent the configuration of each http listener.|`list(object({}))`|n/a|yes|
|backend\_http\_settings|List of objects that represent the configuration of each backend http settings.|`list(object({}))`|n/a|yes|
|request\_routing\_rules|List of objects that represent the configuration of each backend request routing rule.|`list(object({}))`|n/a|yes|

The `sku` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|tier|The Tier of the SKU to use for this Application Gateway. Possible values are `Standard`, `Standard_v2`, `WAF` and `WAF_v2`.|`string`|n/a|yes|
|size|The Size to use for this Application Gateway. Possible values are `Standard_Small`, `Standard_Medium`, `Standard_Large`, `Standard_v2`, `WAF_Medium`, `WAF_Large` and `WAF_v2`.|`string`|n/a|yes|
|capacity|The Capacity to use for this Application Gateway. When using a v1 SKU this value must be between `1` and `32`, and `1` to `125` for a v2 SKU.|`number`|`null`|no|

The `autoscale_configuration` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|min\_capacity|Minimum capacity for autoscaling. Accepted values are in the range `0` to `100`.|`number`|n/a|yes|
|max\_capacity|Maximum capacity for autoscaling. Accepted values are in the range `2` to `125`.|`number`|n/a|yes|

The `frontend_ip_configuration` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|public\_ip\_address\_id|The ID of a Public IP Address which the Application Gateway should use.|`string`|`null`|no|
|private\_ip\_address|The Private IP Address to use for the Application Gateway.|`string`|`null`|no|
|private\_ip\_address\_allocation|The Allocation Method for the Private IP Address. Possible values are `Dynamic` and `Static`.|`string`|`null`|no|

The `backend_address_pools` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The name of the Backend Address Pool.|`string`|n/a|yes|
|private\_ip\_address|A list of IP Addresses which should be part of the Backend Address Pool.|`list(string)`|`null`|no|

The `ssl_certificates` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of the SSL certificate that is unique within this Application Gateway.|`string`|n/a|yes|
|data|PFX certificate. Required if `key_vault_secret_id` is not set.|`string`|`null`|no|
|password|Password for the pfx file specified in data. Required if data is set.|`string`|`null`|no|
|key\_vault\_secret\_id|Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set.|`string`|`null`|no|

The `http_listeners` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of the HTTP Listener.|`string`|n/a|yes|
|frontend\_ip\_configuration|The frontend ip configuration to use for this HTTP Listener. Possible values are `Public` and `Private`.|`string`|n/a|yes|
|port|The port used for this HTTP Listener.|`number`|n/a|yes|
|protocol|The Protocol to use for this HTTP Listener. Possible values are `Http` and `Https`.|`string`|n/a|yes|
|host\_name|The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to Multi site|`string`|`null`|no|
|ssl\_certificate\_name|The name of the associated SSL Certificate which should be used for this HTTP Listener.|`string`|`null`|no|

The `probes` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of the Probe.|`string`|n/a|yes|
|host|The Hostname used for this Probe. If the Application Gateway is configured for a single site, by default the Host name should be specified as `127.0.0.1`, unless otherwise configured in custom probe. Cannot be set if `pick_host_name_from_backend_http_settings` is set to `true`.|`string`|`null`|no|
|protocol|The Protocol used for this Probe. Possible values are `Http` and `Https`.|`string`|n/a|yes|
|path|The Path used for this Probe.|`string`|`null`|no|
|interval|The Interval between two consecutive probes in seconds. Possible values range from `1` second to a maximum of `86400` seconds.|`number`|`null`|no|
|timeout|The Timeout used for this Probe, which indicates when a probe becomes unhealthy. Possible values range from `1` second to a maximum of `86400` seconds.|`string`|`null`|no|
|unhealthy\_threshold|The Unhealthy Threshold for this Probe, which indicates the amount of retries which should be attempted before a node is deemed unhealthy. Possible values are from `1` to `20`.|`string`|`null`|no|

The `backend_http_settings` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The name of the Backend HTTP Settings Collection.|`string`|n/a|yes|
|port|The port which should be used for this Backend HTTP Settings Collection.|`string`|n/a|yes|
|protocol|The Protocol which should be used. Possible values are `Http` and `Https`.|`string`|n/a|yes|
|request\_timeout|The request timeout in seconds, which must be between `1` and `86400` seconds.|`number`|n/a|yes|
|host\_name|Host header to be sent to the backend servers. Cannot be set if `pick_host_name_from_backend_address` is set to `true`.|`string`|`null`|no|
|probe\_name|The name of an associated HTTP Probe.|`string`|`null`|no|

The `request_routing_rules` supports the following:

| Name | Description | Type | Default | Required |
| ---- | ------------| :--: | :-----: | :------: |
|name|The Name of this Request Routing Rule.|`string`|n/a|yes|
|http\_listener\_name|The Name of the HTTP Listener which should be used for this Routing Rule.|`string`|n/a|yes|
|backend\_address\_pool\_name|The Name of the Backend Address Pool which should be used for this Routing Rule.|`string`|n/a|yes|
|backend\_http\_settings\_name|The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule.|`string`|n/a|yes|

## Outputs

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
