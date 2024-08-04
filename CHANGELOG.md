<!-- markdownlint-disable MD041 -->
## 2.0.0 (Unrelease)

BREAKING CHANGES:

* dependencies: updating to `v2.0.0` minimum of terraform.
* dependencies: updating to `v3.40.0` minimum of hashicorp/azurerm provider.
* The internal name by which the `azurerm_application_gateway` resource is defined was defined as `appgw`. This has been changed by `main` to maintain the internal consistency of the module, so the resources deployed in the previous version of the module are not compatible with this new version.

ENHANCEMENTS:

* The `sku.capacity` parameter changes the `string` type to `number` and is now an optional parameter.
* The `autoscale_configuration.min_capacity` parameter changes type `string` to `number`.
* The `autoscale_configuration.max_capacity` parameter changes type `string` to `number`.
* The `sku.capacity` parameter is now a single parameter with the name `capacity`.

FEATURES:

* **New Parameter**: `zones`
* **New Parameter**: `sku_name`
* **New Parameter**: `enable_http2`
* **New Parameter**: `firewall_policy_id`
* **New Parameter**: `capacity`
* **New Parameter**: `frontend_ip_configuration.subnet_id`
* **New Parameter**: `backend_address_pool.fqdns`

DEPRECATIONS:

[waf-config-deprecate]: https://azure.microsoft.com/en-us/updates/retirement-support-for-application-gateway-web-application-firewall-v2-configuration-is-ending/
[appgw-sku-deprecate]: https://azure.microsoft.com/en-us/updates/application-gateway-v1-will-be-retired-on-28-april-2026-transition-to-application-gateway-v2/

* **Parameter**: `waf_configuration` is deprecated in favor of `firewall_policy_id`. WAF configuration must now be performed using a firewall policy. [Retirement: Support for Application Gateway Web Application Firewall v2 Configuration is ending][waf-config-deprecate].
* **Parameter**: `sku` is deprecated in favor of `sku_name`. The `Standard_Small`, `Standard_Medium`, `Standard_Large` and `WAF_Medium` sku types are also deprecated. [Application Gateway V1 will be retired on 28 April 2026– Transition to Application Gateway V2][appgw-sku-deprecate].
* **Parameter**: `private_ip_address_allocation` is deprecated.

## 1.2.0 (January 27, 2022)

FEATURES:

* **New Parameter:** `autoscale_configuration`
* **New Parameter:** `autoscale_configuration.min_capacity`
* **New Parameter:** `autoscale_configuration.max_capacity`
* **New Parameter:** `waf_configuration`
* **New Parameter:** `waf_configuration.enabled`
* **New Parameter:** `waf_configuration.firewall_mode`
* **New Parameter:** `waf_configuration.rule_set_version`

CHANGES:

* **Parameter** `sku.capacity`: It is now an optional parameter with the default value `null`.

## 1.1.0 (January 24, 2021)

FEATURES:

* **New Parameter:** `identity_id`
* **New Parameter:** `ssl_certificates`
* **New Parameter:** `ssl_certificates.name`
* **New Parameter:** `ssl_certificates.data`
* **New Parameter:** `ssl_certificates.password`
* **New Parameter:** `ssl_certificates.key_vault_secret_id`
* **New Parameter:** `http_listeners.host_name`
* **New Parameter:** `http_listeners.ssl_certificate_name`
* **New Parameter:** `probe`
* **New Parameter:** `probe.name`
* **New Parameter:** `probe.host`
* **New Parameter:** `probe.protocol`
* **New Parameter:** `probe.path`
* **New Parameter:** `probe.interval`
* **New Parameter:** `probe.timeout`
* **New Parameter:** `probe.unhealthy_threshold`
* **New Parameter:** `backend_http_settings.host_name`
* **New Parameter:** `backend_http_settings.probe_name`

BUG FIXES:

* **Output** `tags`: Now have a correct output of the different tags.

## 1.0.0 (December 30, 2020)

FEATURES:

* **New Parameter:** `name`
* **New Parameter:** `resource_group_name`
* **New Parameter:** `location`
* **New Parameter:** `sku`
* **New Parameter:** `sku.tier`
* **New Parameter:** `sku.size`
* **New Parameter:** `sku.capacity`
* **New Parameter:** `subnet_id`
* **New Parameter:** `frontend_ip_configuration`
* **New Parameter:** `frontend_ip_configuration.public_ip_address_id`
* **New Parameter:** `frontend_ip_configuration.private_ip_address`
* **New Parameter:** `frontend_ip_configuration.private_ip_address_allocation`
* **New Parameter:** `backend_address_pools`
* **New Parameter:** `backend_address_pools.name`
* **New Parameter:** `backend_address_pools.ip_addresses`
* **New Parameter:** `http_listeners`
* **New Parameter:** `http_listeners.name`
* **New Parameter:** `http_listeners.port`
* **New Parameter:** `http_listeners.protocol`
* **New Parameter:** `backend_http_settings`
* **New Parameter:** `backend_http_settings.name`
* **New Parameter:** `backend_http_settings.port`
* **New Parameter:** `backend_http_settings.protocol`
* **New Parameter:** `backend_http_settings.request_timeout`
* **New Parameter:** `request_routing_rules`
* **New Parameter:** `request_routing_rules.name`
* **New Parameter:** `request_routing_rules.http_listener_name`
* **New Parameter:** `request_routing_rules.backend_address_pool_name`
* **New Parameter:** `request_routing_rules.backend_http_settings_name`
* **New Parameter:** `tags`
