# Private Endpoint Connection submodule for App Service Environment (ASE)
resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.hosting_environment_id
  type      = "Microsoft.Web/hostingEnvironments/privateEndpointConnections@2025-03-01"
  body = {
    properties = {
      ipAddresses = var.ip_addresses
      privateLinkServiceConnectionState = {
        actionsRequired = var.private_link_service_connection_state.actions_required
        description     = var.private_link_service_connection_state.description
        status          = var.private_link_service_connection_state.status
      }
    }
  }
  response_export_values = ["properties.provisioningState"]
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
