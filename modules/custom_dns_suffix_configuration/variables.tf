variable "hosting_environment_resource_id" {
  type        = string
  description = "The resource ID of the App Service Environment (ASE) to configure the custom DNS suffix for."
  nullable    = false
}

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

variable "key_vault_reference_identity" {
  type        = string
  default     = null
  description = "The user-assigned identity to use for resolving the key vault certificate reference. If not specified, the system-assigned ASE identity will be used if available."
}
