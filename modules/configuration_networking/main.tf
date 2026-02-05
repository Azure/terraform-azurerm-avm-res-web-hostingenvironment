# Networking Configuration submodule for App Service Environment
resource "azapi_resource" "this" {
  name      = "networking"
  parent_id = var.hosting_environment_id
  type      = "Microsoft.Web/hostingEnvironments/configurations@2024-04-01"
  body = {
    kind = var.kind
    properties = {
      allowNewPrivateEndpointConnections = var.allow_new_private_endpoint_connections
      ftpEnabled                         = var.ftp_enabled
      inboundIpAddressOverride           = var.inbound_ip_address_override
      remoteDebugEnabled                 = var.remote_debug_enabled
    }
  }
  response_export_values = [
    "properties.externalInboundIpAddresses",
    "properties.internalInboundIpAddresses",
    "properties.linuxOutboundIpAddresses",
    "properties.windowsOutboundIpAddresses"
  ]
  retry = var.retry != null ? {
    error_message_regex  = var.retry.error_message_regex
    interval_seconds     = var.retry.interval_seconds
    max_interval_seconds = var.retry.max_interval_seconds
  } : null
  schema_validation_enabled = true

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}
