# Networking Configuration for App Service Environment (ASE)
# This uses azapi_update_resource because networking configuration properties
# are read-only at ASE create time and must be set via a separate update.
resource "azapi_update_resource" "networking" {
  name      = "networking"
  parent_id = var.hosting_environment_resource_id
  type      = "Microsoft.Web/hostingEnvironments/configurations@2025-03-01"
  body = {
    properties = {
      allowNewPrivateEndpointConnections = var.allow_new_private_endpoint_connections
      ftpEnabled                         = var.ftp_enabled
      remoteDebugEnabled                 = var.remote_debug_enabled
    }
  }
  response_export_values = [
    "properties.allowNewPrivateEndpointConnections",
    "properties.ftpEnabled",
    "properties.remoteDebugEnabled",
    "properties.externalInboundIpAddresses",
    "properties.internalInboundIpAddresses",
    "properties.linuxOutboundIpAddresses",
    "properties.windowsOutboundIpAddresses"
  ]
}
