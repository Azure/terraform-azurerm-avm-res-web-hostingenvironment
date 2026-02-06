variable "hosting_environment_id" {
  type        = string
  description = "The resource ID of the App Service Environment (ASE) to configure."
  nullable    = false
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  default     = null
  description = "Enable new private endpoint connection creation on the App Service Environment (ASE)."
}

variable "ftp_enabled" {
  type        = bool
  default     = null
  description = "Enable FTP on the App Service Environment (ASE)."
}

variable "remote_debug_enabled" {
  type        = bool
  default     = null
  description = "Enable Remote Debug on the App Service Environment (ASE)."
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
