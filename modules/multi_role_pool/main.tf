# Multi-Role Pool (Front-End Pool) submodule for App Service Environment
# Note: This is primarily used for ASEv1/v2. ASEv3 manages front-end pools internally.
resource "azapi_resource" "this" {
  name      = "default"
  parent_id = var.hosting_environment_id
  type      = "Microsoft.Web/hostingEnvironments/multiRolePools@2024-04-01"
  body = {
    kind = var.kind
    properties = {
      computeMode  = var.compute_mode
      workerCount  = var.worker_count
      workerSize   = var.worker_size
      workerSizeId = var.worker_size_id
    }
    sku = var.sku != null ? {
      capabilities = var.sku.capabilities != null ? [
        for cap in var.sku.capabilities : {
          name   = cap.name
          reason = cap.reason
          value  = cap.value
        }
      ] : null
      capacity  = var.sku.capacity
      family    = var.sku.family
      locations = var.sku.locations
      name      = var.sku.name
      size      = var.sku.size
      skuCapacity = var.sku.sku_capacity != null ? {
        default        = var.sku.sku_capacity.default
        elasticMaximum = var.sku.sku_capacity.elastic_maximum
        maximum        = var.sku.sku_capacity.maximum
        minimum        = var.sku.sku_capacity.minimum
        scaleType      = var.sku.sku_capacity.scale_type
      } : null
      tier = var.sku.tier
    } : null
  }
  response_export_values    = ["*"]
  schema_validation_enabled = true

  timeouts {
    create = "1h"
    delete = "1h"
    read   = "5m"
    update = "1h"
  }
}
