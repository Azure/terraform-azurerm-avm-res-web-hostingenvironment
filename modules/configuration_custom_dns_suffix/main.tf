# Custom DNS Suffix Configuration submodule for App Service Environment
resource "azapi_resource" "this" {
  name      = "customdnssuffix"
  parent_id = var.hosting_environment_id
  type      = "Microsoft.Web/hostingEnvironments/configurations@2024-04-01"
  body = {
    kind = var.kind
    properties = {
      certificateUrl            = var.certificate_url
      dnsSuffix                 = var.dns_suffix
      keyVaultReferenceIdentity = var.key_vault_reference_identity
    }
  }
  response_export_values = [
    "properties.provisioningState",
    "properties.provisioningDetails"
  ]
  schema_validation_enabled = true

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "5m"
    update = "30m"
  }
}
