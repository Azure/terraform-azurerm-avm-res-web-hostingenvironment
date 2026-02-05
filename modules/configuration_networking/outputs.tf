output "external_inbound_ip_addresses" {
  description = "The external inbound IP addresses."
  value       = try(azapi_resource.this.output.properties.externalInboundIpAddresses, [])
}

output "internal_inbound_ip_addresses" {
  description = "The internal inbound IP addresses."
  value       = try(azapi_resource.this.output.properties.internalInboundIpAddresses, [])
}

output "linux_outbound_ip_addresses" {
  description = "The Linux outbound IP addresses."
  value       = try(azapi_resource.this.output.properties.linuxOutboundIpAddresses, [])
}

output "name" {
  description = "The name of the networking configuration."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object for the networking configuration."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the networking configuration."
  value       = azapi_resource.this.id
}

output "windows_outbound_ip_addresses" {
  description = "The Windows outbound IP addresses."
  value       = try(azapi_resource.this.output.properties.windowsOutboundIpAddresses, [])
}
