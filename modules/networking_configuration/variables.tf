variable "hosting_environment_resource_id" {
  type        = string
  description = "The resource ID of the App Service Environment (ASE) to configure networking for."
  nullable    = false
}

variable "location" {
  type        = string
  description = "The Azure region for this module's resources or telemetry deployment."
  nullable    = false
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  default     = true
  description = "Enable new private endpoint connection creation on the App Service Environment (ASE). Defaults to true."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "ftp_enabled" {
  type        = bool
  default     = false
  description = "Enable FTP on the App Service Environment (ASE). Defaults to false."
}

variable "remote_debug_enabled" {
  type        = bool
  default     = false
  description = "Enable Remote Debug on the App Service Environment (ASE). Defaults to false."
  nullable    = false
}
