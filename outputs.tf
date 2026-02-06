output "dns_suffix" {
  description = "The DNS suffix of the App Service Environment (ASE)."
  value       = try(azapi_resource.this.output.properties.dnsSuffix, null)
}

output "external_inbound_ip_addresses" {
  description = "The external inbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_resource.this.output.properties.networkingConfiguration.properties.externalInboundIpAddresses, [])
}

output "internal_inbound_ip_addresses" {
  description = "The internal inbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_resource.this.output.properties.networkingConfiguration.properties.internalInboundIpAddresses, [])
}

output "linux_outbound_ip_addresses" {
  description = "The Linux outbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_resource.this.output.properties.networkingConfiguration.properties.linuxOutboundIpAddresses, [])
}

output "location" {
  description = "The location of the App Service Environment (ASE)."
  value       = azapi_resource.this.location
}

output "name" {
  description = "The name of the App Service Environment (ASE)."
  value       = azapi_resource.this.name
}

output "private_endpoint_connections" {
  description = "The private endpoint connections created for the App Service Environment (ASE)."
  value = {
    for k, v in module.private_endpoint_connection : k => {
      name               = v.name
      resource_id        = v.resource_id
      provisioning_state = v.provisioning_state
    }
  }
}

output "resource_id" {
  description = "The resource ID of the App Service Environment (ASE)."
  value       = azapi_resource.this.id
}

output "system_assigned_mi_principal_id" {
  description = "The principal ID of the system-assigned managed identity."
  value       = try(azapi_resource.this.identity[0].principal_id, null)
}

output "windows_outbound_ip_addresses" {
  description = "The Windows outbound IP addresses of the App Service Environment (ASE)."
  value       = try(azapi_resource.this.output.properties.networkingConfiguration.properties.windowsOutboundIpAddresses, [])
}
