output "name" {
  description = "The name of the custom DNS suffix configuration."
  value       = azapi_resource.this.name
}

output "provisioning_details" {
  description = "The provisioning details of the custom DNS suffix configuration."
  value       = try(azapi_resource.this.output.properties.provisioningDetails, null)
}

output "provisioning_state" {
  description = "The provisioning state of the custom DNS suffix configuration."
  value       = try(azapi_resource.this.output.properties.provisioningState, null)
}

output "resource_id" {
  description = "The resource ID of the custom DNS suffix configuration."
  value       = azapi_resource.this.id
}
