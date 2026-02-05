variable "certificate_url" {
  type        = string
  description = "The URL referencing the Azure Key Vault certificate secret that should be used as the default SSL/TLS certificate for sites with the custom domain suffix."
  nullable    = false
}

variable "dns_suffix" {
  type        = string
  description = "The default custom domain suffix to use for all sites deployed on the ASE."
  nullable    = false
}

variable "hosting_environment_id" {
  type        = string
  description = "The resource ID of the hosting environment (App Service Environment) to configure."
  nullable    = false
}

variable "key_vault_reference_identity" {
  type        = string
  default     = null
  description = "The user-assigned identity to use for resolving the key vault certificate reference. If not specified, the system-assigned ASE identity will be used if available."
}

variable "kind" {
  type        = string
  default     = null
  description = "Kind of resource."
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), null)
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
  })
  default     = null
  description = <<DESCRIPTION
  Retry configuration for transient errors. The following properties can be specified:

  - `error_message_regex` - (Optional) A list of regular expressions to match against error messages.
  - `interval_seconds` - (Optional) The initial interval in seconds between retries.
  - `max_interval_seconds` - (Optional) The maximum interval in seconds between retries.
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
  })
  default     = {}
  description = "Timeouts for resource operations."
}
