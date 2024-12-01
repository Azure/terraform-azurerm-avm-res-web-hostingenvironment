resource "azurerm_app_service_environment_v3" "this" {
  name                                   = var.name # calling code must supply the name
  resource_group_name                    = var.resource_group_name
  subnet_id                              = var.subnet_id
  allow_new_private_endpoint_connections = var.allow_new_private_endpoint_connections
  dedicated_host_count                   = var.dedicated_host_count
  internal_load_balancing_mode           = var.internal_load_balancing_mode
  remote_debugging_enabled               = var.remote_debugging_enabled
  tags                                   = var.tags
  zone_redundant                         = var.zone_redundant

  dynamic "cluster_setting" {
    for_each = var.cluster_setting

    content {
      name  = cluster_setting.name
      value = cluster_setting.value
    }
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_app_service_environment_v3.this.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_app_service_environment_v3.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
