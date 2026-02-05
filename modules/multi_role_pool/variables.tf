variable "hosting_environment_id" {
  type        = string
  description = "The resource ID of the hosting environment (App Service Environment) to configure."
  nullable    = false
}

variable "compute_mode" {
  type        = string
  default     = null
  description = "Shared or dedicated app hosting. Possible values are 'Dedicated', 'Dynamic', or 'Shared'."

  validation {
    condition     = var.compute_mode == null || contains(["Dedicated", "Dynamic", "Shared"], var.compute_mode)
    error_message = "Possible values are 'Dedicated', 'Dynamic', or 'Shared'."
  }
}

variable "kind" {
  type        = string
  default     = null
  description = "Kind of resource."
}

variable "sku" {
  type = object({
    capabilities = optional(list(object({
      name   = optional(string, null)
      reason = optional(string, null)
      value  = optional(string, null)
    })), null)
    capacity  = optional(number, null)
    family    = optional(string, null)
    locations = optional(list(string), null)
    name      = optional(string, null)
    size      = optional(string, null)
    sku_capacity = optional(object({
      default         = optional(number, null)
      elastic_maximum = optional(number, null)
      maximum         = optional(number, null)
      minimum         = optional(number, null)
      scale_type      = optional(string, null)
    }), null)
    tier = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Description of a SKU for a scalable resource. The following properties can be specified:

  - `capabilities` - (Optional) Capabilities of the SKU.
    - `name` - Name of the SKU capability.
    - `reason` - Reason of the SKU capability.
    - `value` - Value of the SKU capability.
  - `capacity` - (Optional) Current number of instances assigned to the resource.
  - `family` - (Optional) Family code of the resource SKU.
  - `locations` - (Optional) Locations of the SKU.
  - `name` - (Optional) Name of the resource SKU.
  - `size` - (Optional) Size specifier of the resource SKU.
  - `sku_capacity` - (Optional) Min, max, and default scale values of the SKU.
    - `default` - Default number of workers for this App Service plan SKU.
    - `elastic_maximum` - Maximum number of Elastic workers for this App Service plan SKU.
    - `maximum` - Maximum number of workers for this App Service plan SKU.
    - `minimum` - Minimum number of workers for this App Service plan SKU.
    - `scale_type` - Available scale configurations for an App Service plan.
  - `tier` - (Optional) Service tier of the resource SKU.
  DESCRIPTION
}

variable "worker_count" {
  type        = number
  default     = null
  description = "Number of instances in the worker pool."
}

variable "worker_size" {
  type        = string
  default     = null
  description = "VM size of the worker pool instances."
}

variable "worker_size_id" {
  type        = number
  default     = null
  description = "Worker size ID for referencing this worker pool."
}
