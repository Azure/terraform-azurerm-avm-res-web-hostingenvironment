output "instance_names" {
  description = "The names of all instances in the worker pool."
  value       = try(azapi_resource.this.output.properties.instanceNames, [])
}

output "name" {
  description = "The name of the worker pool."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object for the worker pool."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the worker pool."
  value       = azapi_resource.this.id
}
