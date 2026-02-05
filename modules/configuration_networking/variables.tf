variable "hosting_environment_id" {
  type        = string
  description = "The resource ID of the hosting environment (App Service Environment) to configure."
  nullable    = false
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  default     = null
  description = "Property to enable and disable new private endpoint connection creation on ASE."
}

variable "ftp_enabled" {
  type        = bool
  default     = null
  description = "Property to enable and disable FTP on ASEV3."
}

variable "inbound_ip_address_override" {
  type        = string
  default     = null
  description = "Customer provided Inbound IP Address. Only able to be set on ASE create."
}

variable "kind" {
  type        = string
  default     = null
  description = "Kind of resource."
}

variable "remote_debug_enabled" {
  type        = bool
  default     = null
  description = "Property to enable and disable Remote Debug on ASEV3."
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
