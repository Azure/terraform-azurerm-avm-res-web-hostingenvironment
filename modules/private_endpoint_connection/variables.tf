variable "hosting_environment_id" {
  type        = string
  description = "The resource ID of the hosting environment (App Service Environment) to create the private endpoint connection in."
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
