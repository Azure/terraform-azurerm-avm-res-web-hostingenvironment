# Main App Service Environment (ASE) resource using AzAPI
resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Web/hostingEnvironments@2025-03-01"
  body = {
    kind = "ASEV3"
    properties = {
      clusterSettings = local.cluster_settings
      customDnsSuffixConfiguration = var.custom_dns_suffix_configuration != null ? {
        properties = {
          certificateUrl            = var.custom_dns_suffix_configuration.certificate_url
          dnsSuffix                 = var.custom_dns_suffix_configuration.dns_suffix
          keyVaultReferenceIdentity = var.custom_dns_suffix_configuration.key_vault_reference_identity
        }
      } : null
      dedicatedHostCount        = var.dedicated_host_count == null ? 0 : var.dedicated_host_count
      dnsSuffix                 = null
      frontEndScaleFactor       = null
      internalLoadBalancingMode = var.internal_load_balancing_mode
      ipsslAddressCount         = null
      multiSize                 = null
      networkingConfiguration = {
        properties = {
          allowNewPrivateEndpointConnections = var.allow_new_private_endpoint_connections
          ftpEnabled                         = var.ftp_enabled
          inboundIpAddressOverride           = var.inbound_ip_address_override
          remoteDebugEnabled                 = var.remote_debug_enabled
        }
      }
      upgradePreference       = var.upgrade_preference
      userWhitelistedIpRanges = null
      virtualNetwork = {
        id     = var.subnet_id
        subnet = null
      }
      zoneRedundant = var.zone_redundancy_enabled
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.dnsSuffix",
    "properties.networkingConfiguration.properties.externalInboundIpAddresses",
    "properties.networkingConfiguration.properties.internalInboundIpAddresses",
    "properties.networkingConfiguration.properties.linuxOutboundIpAddresses",
    "properties.networkingConfiguration.properties.windowsOutboundIpAddresses"
  ]
  retry = var.retry != null ? {
    error_message_regex  = var.retry.error_message_regex
    interval_seconds     = var.retry.interval_seconds
    max_interval_seconds = var.retry.max_interval_seconds
  } : null
  schema_validation_enabled = true
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned || length(local.managed_identities.user_assigned_resource_ids) > 0 ? [1] : []

    content {
      type         = local.managed_identities.type
      identity_ids = local.managed_identities.user_assigned_resource_ids
    }
  }
  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }

  lifecycle {
    ignore_changes = [
      body.properties.dnsSuffix,
      body.properties.frontEndScaleFactor,
      body.properties.ipsslAddressCount,
      body.properties.multiSize,
      body.properties.userWhitelistedIpRanges,
      body.properties.virtualNetwork.subnet
    ]
  }
}

# AVM Interfaces Module - handles diagnostic settings, locks, role assignments
module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.5.0"

  diagnostic_settings                  = var.diagnostic_settings
  enable_telemetry                     = var.enable_telemetry
  lock                                 = var.lock
  role_assignment_definition_scope     = azapi_resource.this.id
  role_assignment_name_use_random_uuid = true
  role_assignments                     = var.role_assignments
}

# Resource Lock using AzAPI
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name                   = module.avm_interfaces.lock_azapi.name
  parent_id              = azapi_resource.this.id
  type                   = module.avm_interfaces.lock_azapi.type
  body                   = module.avm_interfaces.lock_azapi.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry = var.retry != null ? {
    error_message_regex  = var.retry.error_message_regex
    interval_seconds     = var.retry.interval_seconds
    max_interval_seconds = var.retry.max_interval_seconds
  } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

# Role Assignments using AzAPI
resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry = var.retry != null ? {
    error_message_regex  = var.retry.error_message_regex
    interval_seconds     = var.retry.interval_seconds
    max_interval_seconds = var.retry.max_interval_seconds
  } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

# Diagnostic Settings using AzAPI
resource "azapi_resource" "diagnostic_setting" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry = var.retry != null ? {
    error_message_regex  = var.retry.error_message_regex
    interval_seconds     = var.retry.interval_seconds
    max_interval_seconds = var.retry.max_interval_seconds
  } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

# Private Endpoint Connections submodule
module "private_endpoint_connection" {
  source   = "./modules/private_endpoint_connection"
  for_each = var.private_endpoint_connections

  hosting_environment_id                = azapi_resource.this.id
  name                                  = coalesce(each.value.name, each.key)
  ip_addresses                          = each.value.ip_addresses
  private_link_service_connection_state = each.value.private_link_service_connection_state
  timeouts                              = each.value.timeouts
}

# Moved blocks for migration from azurerm provider to azapi provider
moved {
  from = azurerm_app_service_environment_v3.this
  to   = azapi_resource.this
}

moved {
  from = azurerm_management_lock.this
  to   = azapi_resource.lock[0]
}

moved {
  from = azurerm_role_assignment.this
  to   = azapi_resource.role_assignment
}

moved {
  from = azurerm_monitor_diagnostic_setting.this
  to   = azapi_resource.diagnostic_setting
}
