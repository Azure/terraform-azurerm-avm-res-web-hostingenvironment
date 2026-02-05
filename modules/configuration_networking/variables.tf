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
