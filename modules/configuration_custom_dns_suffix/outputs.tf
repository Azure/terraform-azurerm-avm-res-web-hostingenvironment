output "name" {
  description = "The name of the custom DNS suffix configuration."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the custom DNS suffix configuration."
  value       = azapi_resource.this.id
}
