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

  dynamic "retry" {
    for_each = var.retry != null ? [var.retry] : []

    content {
      error_message_regex  = retry.value.error_message_regex
      interval_seconds     = retry.value.interval_seconds
      max_interval_seconds = retry.value.max_interval_seconds
      multiplier           = retry.value.multiplier
      randomization_factor = retry.value.randomization_factor
    }
  }
  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}
