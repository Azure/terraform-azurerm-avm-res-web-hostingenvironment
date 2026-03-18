output "dns_suffix" {
  description = "The DNS suffix of the App Service Environment (ASE)."
  value       = try(azapi_resource.this.output.properties.dnsSuffix, null)
}

output "external_inbound_ip_addresses" {
  description = "The external inbound IP addresses of the App Service Environment (ASE)."
  value       = module.networking_configuration.external_inbound_ip_addresses
}

output "internal_inbound_ip_addresses" {
  description = "The internal inbound IP addresses of the App Service Environment (ASE)."
  value       = module.networking_configuration.internal_inbound_ip_addresses
}

output "linux_outbound_ip_addresses" {
  description = "The Linux outbound IP addresses of the App Service Environment (ASE)."
  value       = module.networking_configuration.linux_outbound_ip_addresses
}

output "name" {
  description = "The name of the App Service Environment (ASE)."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the App Service Environment (ASE)."
  value       = azapi_resource.this.id
}

output "system_assigned_managed_identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity."
  value       = try(azapi_resource.this.identity[0].principal_id, null)
}

output "windows_outbound_ip_addresses" {
  description = "The Windows outbound IP addresses of the App Service Environment (ASE)."
  value       = module.networking_configuration.windows_outbound_ip_addresses
}
