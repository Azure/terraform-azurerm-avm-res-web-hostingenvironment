output "name" {
  description = "The name of the private endpoint connection."
  value       = azapi_resource.this.name
}

output "provisioning_state" {
  description = "The provisioning state of the private endpoint connection."
  value       = try(azapi_resource.this.output.properties.provisioningState, null)
}

output "resource" {
  description = "The full resource object for the private endpoint connection."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the private endpoint connection."
  value       = azapi_resource.this.id
}
