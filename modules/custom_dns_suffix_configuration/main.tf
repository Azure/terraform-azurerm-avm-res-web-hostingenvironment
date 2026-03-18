# Custom DNS Suffix Configuration for App Service Environment (ASE)
# This uses azapi_update_resource because custom DNS suffix configuration
# is read-only at ASE create time and must be set via a separate update.
resource "azapi_update_resource" "custom_dns_suffix" {
  type      = "Microsoft.Web/hostingEnvironments/configurations@2025-03-01"
  name      = "customdnssuffix"
  parent_id = var.hosting_environment_resource_id
  body = {
    properties = {
      certificateUrl            = var.certificate_url
      dnsSuffix                 = var.dns_suffix
      keyVaultReferenceIdentity = var.key_vault_reference_identity
    }
  }
  response_export_values = [
    "properties.certificateUrl",
    "properties.dnsSuffix",
    "properties.keyVaultReferenceIdentity",
    "properties.provisioningState"
  ]
}
