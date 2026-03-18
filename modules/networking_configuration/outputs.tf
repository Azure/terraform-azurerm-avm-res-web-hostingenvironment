output "allow_new_private_endpoint_connections" {
  description = "Whether new private endpoint connections are allowed."
  value       = azapi_update_resource.networking.output.properties.allowNewPrivateEndpointConnections
}

output "external_inbound_ip_addresses" {
  description = "The external inbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_update_resource.networking.output.properties.externalInboundIpAddresses, [])
}

output "ftp_enabled" {
  description = "Whether FTP is enabled."
  value       = azapi_update_resource.networking.output.properties.ftpEnabled
}

output "internal_inbound_ip_addresses" {
  description = "The internal inbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_update_resource.networking.output.properties.internalInboundIpAddresses, [])
}

output "linux_outbound_ip_addresses" {
  description = "The Linux outbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_update_resource.networking.output.properties.linuxOutboundIpAddresses, [])
}

output "remote_debug_enabled" {
  description = "Whether remote debug is enabled."
  value       = azapi_update_resource.networking.output.properties.remoteDebugEnabled
}

output "resource_id" {
  description = "The resource ID of the networking configuration."
  value       = azapi_update_resource.networking.id
}

output "windows_outbound_ip_addresses" {
  description = "The Windows outbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_update_resource.networking.output.properties.windowsOutboundIpAddresses, [])
}
