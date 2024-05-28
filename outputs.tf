output "name" {
  description = "The name of the resource."
  value       = azurerm_app_service_environment_v3.this.name
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "The full resource object"
  value       = azurerm_app_service_environment_v3.this
}

output "resource_id" {
  description = "This is the full output for the resource."
  value       = azurerm_app_service_environment_v3.this.id
}
