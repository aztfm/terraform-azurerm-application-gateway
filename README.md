# Azure Application Gateway - Terraform Module
![Testing module](https://github.com/aztfm/terraform-azurerm-application-gateway/workflows/Testing%20module/badge.svg?branch=main)
[![TF Registry](https://img.shields.io/badge/terraform-registry-blueviolet.svg)](https://registry.terraform.io/modules/aztfm/application-gateway/azurerm/)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/aztfm/terraform-azurerm-application-gateway)

## Version compatibility

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 1.x.x       | >= 0.13.x         | >= 2.0.0        |

## Parameters

The following parameters are supported:

| Name                        | Description                                                                            |        Type         | Default | Required |
| --------------------------- | -------------------------------------------------------------------------------------- | :-----------------: | :-----: | :------: |
| name                        | The name of the Application Gateway.                                                   |      `string`       |   n/a   |   yes    |
| resource\_group\_name       | The name of the resource group in which to create the Application Gateway.             |      `string`       |   n/a   |   yes    |
| location                    | The location/region where the Application Gateway is created.                          |      `string`       |   n/a   |   yes    |
| sku                         | A mapping with the sku configuration of the application gateway.                       |    `map(string)`    |   n/a   |   yes    |
| subnet\_id                  | The ID of the Subnet which the Application Gateway should be connected to.             |      `string`       |   n/a   |   yes    |
| frontend\_ip\_configuration | A mapping the front ip configuration.                                                  |    `map(string)`    |   n/a   |   yes    |
| backend\_address\_pools     | List of objects that represent the configuration of each backend address pool.         | `list(map(string))` |   n/a   |   yes    |
| identity\_id                | Specifies a single user managed identity id to be assigned to the Application Gateway. |      `string`       |  null   |    no    |
| ssl\_certificates           | List of objects that represent the configuration of each ssl certificate.              | `list(map(string))` |   []    |    no    |
| http\_listeners             | List of objects that represent the configuration of each http listener.                | `list(map(string))` |   n/a   |   yes    |
| backend\_http\_settings     | List of objects that represent the configuration of each backend http settings.        | `list(map(string))` |   n/a   |   yes    |
| request\_routing\_rules     | List of objects that represent the configuration of each backend request routing rule. | `list(map(string))` |   n/a   |   yes    |
| tags                        | A mapping of tags to assign to the resource.                                           |    `map(string)`    |  `{}`   |    no    |

##
The `sku` supports the following:

| Name     | Description                                                                                                                                                                      |   Type   | Default | Required |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: | :-----: | :------: |
| tier     | The Tier of the SKU to use for this Application Gateway. Possible values are `Standard`, `Standard_v2`, `WAF` and `WAF_v2`.                                                      | `string` |   n/a   |   yes    |
| size     | The Size to use for this Application Gateway. Possible values are `Standard_Small`, `Standard_Medium`, `Standard_Large`, `Standard_v2`, `WAF_Medium`, `WAF_Large`, and `WAF_v2`. | `string` |   n/a   |   yes    |
| capacity | The Capacity to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU.                                            | `string` |   n/a   |   yes    |

##
The `frontend_ip_configuration` supports the following:

| Name                             | Description                                                                                   |   Type   | Default | Required |
| -------------------------------- | --------------------------------------------------------------------------------------------- | :------: | :-----: | :------: |
| public_ip_address_id             | The ID of a Public IP Address which the Application Gateway should use.                       | `string` | `null`  |    no    |
| private\_ip\_address             | The Private IP Address to use for the Application Gateway.                                    | `string` | `null`  |    no    |
| private\_ip\_address\_allocation | The Allocation Method for the Private IP Address. Possible values are `Dynamic` and `Static`. | `string` | `null`  |    no    |

##
The `backend_address_pools` supports the following:

| Name          | Description                                                              |   Type   | Default | Required |
| ------------- | ------------------------------------------------------------------------ | :------: | :-----: | :------: |
| name          | The name of the Backend Address Pool.                                    | `string` |   n/a   |   yes    |
| ip\_addresses | A list of IP Addresses which should be part of the Backend Address Pool. | `string` | `null`  |    no    |

##
The `ssl_certificates` supports the following:

| Name                | Description                                                                                                                                                                                         |   Type   | Default | Required |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: | :-----: | :------: |
| name                | The Name of the SSL certificate that is unique within this Application Gateway.                                                                                                                     | `string` |   n/a   |   yes    |
| data                | PFX certificate. Required if key_vault_secret_id is not set.                                                                                                                                        | `string` | `null`  |    no    |
| password            | Password for the pfx file specified in data. Required if data is set.                                                                                                                               | `string` | `null`  |    no    |
| key_vault_secret_id | Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set. | `string` | `null`  |    no    |

##
The `http_listeners` supports the following:

| Name     | Description                                                                         |   Type   | Default | Required |
| -------- | ----------------------------------------------------------------------------------- | :------: | :-----: | :------: |
| name     | The Name of the HTTP Listener.                                                      | `string` |   n/a   |   yes    |
| port     | The port used for this HTTP Listener.                                               | `string` |   n/a   |   yes    |
| protocol | The Protocol to use for this HTTP Listener. Possible values are `Http` and `Https`. | `string` |   n/a   |   yes    |

##
The `backend_http_settings` supports the following:

| Name             | Description                                                                |   Type   | Default | Required |
| ---------------- | -------------------------------------------------------------------------- | :------: | :-----: | :------: |
| name             | The name of the Backend HTTP Settings Collection.                          | `string` |   n/a   |   yes    |
| port             | The port which should be used for this Backend HTTP Settings Collection.   | `string` |   n/a   |   yes    |
| protocol         | The Protocol which should be used. Possible values are `Http` and `Https`. | `string` |   n/a   |   yes    |
| request\_timeout | The request timeout in seconds, which must be between 1 and 86400 seconds. | `string` |   n/a   |   yes    |

##
The `request_routing_rules` supports the following:

| Name                         | Description                                                                                  |   Type   | Default | Required |
| ---------------------------- | -------------------------------------------------------------------------------------------- | :------: | :-----: | :------: |
| name                         | The Name of this Request Routing Rule.                                                       | `string` |   n/a   |   yes    |
| http\_listener\_name         | The Name of the HTTP Listener which should be used for this Routing Rule.                    | `string` |   n/a   |   yes    |
| backend\_address\_pool\_name | The Name of the Backend Address Pool which should be used for this Routing Rule.             | `string` |   n/a   |   yes    |
| backend\_http_settings\_name | The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule. | `string` |   n/a   |   yes    |

## Outputs

The following outputs are exported:

| Name                    | Description                                                                |
| ----------------------- | -------------------------------------------------------------------------- |
| id                      | The application gateway configuration ID.                                  |
| name                    | The name of the application gateway.                                       |
| resource\_group\_name   | The name of the resource group in which to create the application gateway. |
| location                | The location/region where the application gateway is created.              |
| backend\_address\_pools | Blocks containing configuration of each backend address pool.              |
| http\_listeners         | Blocks containing configuration of each http listener.                     |
| backend\_http\_settings | Blocks containing configuration of each backend http settings.             |
| request\_routing\_rules | Blocks containing configuration of each request routing rule.              |
| tags                    | The tags assigned to the resource.                                         |