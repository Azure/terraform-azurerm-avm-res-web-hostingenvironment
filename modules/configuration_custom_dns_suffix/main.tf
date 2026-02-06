# Custom DNS Suffix Configuration submodule for App Service Environment (ASE)
resource "azapi_resource" "this" {
  name      = "customdnssuffix"
  parent_id = var.hosting_environment_id
  type      = "Microsoft.Web/hostingEnvironments/configurations@2025-03-01"
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
  retry = var.retry != null ? {
    error_message_regex  = var.retry.error_message_regex
    interval_seconds     = var.retry.interval_seconds
    max_interval_seconds = var.retry.max_interval_seconds
  } : null
  schema_validation_enabled = true

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}
