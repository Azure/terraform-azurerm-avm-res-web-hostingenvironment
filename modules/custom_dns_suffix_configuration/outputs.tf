output "certificate_url" {
  description = "The URL of the certificate used for the custom DNS suffix."
  value       = azapi_update_resource.custom_dns_suffix.output.properties.certificateUrl
}

output "dns_suffix" {
  description = "The custom DNS suffix applied to the ASE."
  value       = azapi_update_resource.custom_dns_suffix.output.properties.dnsSuffix
}

output "key_vault_reference_identity" {
  description = "The identity used for resolving the key vault certificate reference."
  value       = try(azapi_update_resource.custom_dns_suffix.output.properties.keyVaultReferenceIdentity, null)
}

output "provisioning_state" {
  description = "The provisioning state of the custom DNS suffix configuration."
  value       = try(azapi_update_resource.custom_dns_suffix.output.properties.provisioningState, null)
}

output "resource_id" {
  description = "The resource ID of the custom DNS suffix configuration."
  value       = azapi_update_resource.custom_dns_suffix.id
}
