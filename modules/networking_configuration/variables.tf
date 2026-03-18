variable "hosting_environment_resource_id" {
  type        = string
  description = "The resource ID of the App Service Environment (ASE) to configure networking for."
  nullable    = false
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  default     = true
  description = "Enable new private endpoint connection creation on the App Service Environment (ASE). Defaults to true."
}

variable "ftp_enabled" {
  type        = bool
  default     = false
  description = "Enable FTP on the App Service Environment (ASE). Defaults to false."
}

variable "remote_debug_enabled" {
  type        = bool
  default     = null
  description = "Enable Remote Debug on the App Service Environment (ASE)."
}
