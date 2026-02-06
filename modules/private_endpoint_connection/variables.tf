variable "hosting_environment_id" {
  type        = string
  description = "The resource ID of the App Service Environment (ASE) to create the private endpoint connection in."
}

variable "name" {
  type        = string
  description = "The name of the private endpoint connection."
}

variable "ip_addresses" {
  type        = list(string)
  default     = []
  description = "A list of IP addresses for the private endpoint."
}

variable "private_link_service_connection_state" {
  type = object({
    actions_required = optional(string, null)
    description      = optional(string, null)
    status           = optional(string, "Approved")
  })
  default     = {}
  description = <<DESCRIPTION
  The state of the private link service connection. The following properties can be specified:

  - `actions_required` - (Optional) Actions required for the connection.
  - `description` - (Optional) A description of the connection.
  - `status` - (Optional) The status of the connection. Possible values are 'Approved', 'Pending', 'Rejected', 'Disconnected'. Defaults to 'Approved'.
  DESCRIPTION
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
