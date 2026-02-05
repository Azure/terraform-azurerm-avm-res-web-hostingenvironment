output "instance_names" {
  description = "The names of all instances in the multi-role pool."
  value       = try(azapi_resource.this.output.properties.instanceNames, [])
}

output "name" {
  description = "The name of the multi-role pool."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object for the multi-role pool."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the multi-role pool."
  value       = azapi_resource.this.id
}
