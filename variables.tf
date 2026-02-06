variable "location" {
  type        = string
  description = "The Azure region where the App Service Environment (ASE) will be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of this resource."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,60}$", var.name))
    error_message = "The name must be 1-60 characters long and contain only alphanumeric characters and hyphens."
  }
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the resource group where the App Service Environment (ASE) will be deployed."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "The parent_id must be a valid Azure resource group resource ID."
  }
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the App Service Environment (ASE) should be connected to. The subnet must be delegated to Microsoft.Web/hostingEnvironments."

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Network/virtualNetworks/subnets", var.subnet_id))
    error_message = "The subnet_id must be a valid Azure subnet resource ID."
  }
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  default     = true
  description = "Enable new private endpoint connection creation on the App Service Environment (ASE). Defaults to true."
}

variable "cluster_settings" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "Custom settings for changing the behavior of the App Service Environment (ASE). These settings are stored in the clusterSettings attribute of the hostingEnvironments Azure Resource Manager entity."
  nullable    = false
}

variable "custom_dns_suffix_configuration" {
  type = object({
    certificate_url              = string
    dns_suffix                   = string
    key_vault_reference_identity = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Custom domain suffix configuration for the App Service Environment (ASE). The following properties can be specified:

  - `certificate_url` - (Required) The URL referencing the Azure Key Vault certificate secret that should be used as the default SSL/TLS certificate for sites with the custom domain suffix.
  - `dns_suffix` - (Required) The default custom domain suffix to use for all sites deployed on the ASE.
  - `key_vault_reference_identity` - (Optional) The user-assigned identity to use for resolving the key vault certificate reference. If not specified, the system-assigned ASE identity will be used if available.
  DESCRIPTION
}

variable "dedicated_host_count" {
  type        = number
  default     = null
  description = "Dedicated Host Count for the App Service Environment (ASE). Possible value is 2. Setting this value will make the ASE use dedicated hosts."

  validation {
    condition     = var.dedicated_host_count == null || var.dedicated_host_count == 2
    error_message = "The number of dedicated hosts must be null or 2."
  }
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of diagnostic settings to create on the App Service Environment (ASE). The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
  - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
  - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.
  DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
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

variable "fips_mode_enabled" {
  type        = bool
  default     = false
  description = "Enable FIPS mode on the App Service Environment (ASE). Enabling this will enforce the use of FIPS compliant ciphers and protocols for Linux: https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings#enable-fips-mode"
}

variable "front_end_tls_cipher_suite_order" {
  type        = string
  default     = null
  description = "The TLS cipher suite order to use on the App Service Environment (ASE). Refer to the docs for valid inputs: https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings#change-tls-cipher-suite-order"
}

variable "ftp_enabled" {
  type        = bool
  default     = false
  description = "Enable FTP on the App Service Environment (ASE)."
}

variable "inbound_ip_address_override" {
  type        = string
  default     = null
  description = "Customer provided Inbound IP Address. Only able to be set on ASE create."
}

variable "internal_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable internal Encryption: https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings#enable-internal-encryption"
}

variable "internal_load_balancing_mode" {
  type        = string
  default     = "Web, Publishing"
  description = "Specifies which endpoints to serve internally in the Virtual Network for the App Service Environment (ASE). Possible values are 'None', 'Web', 'Publishing', or 'Web, Publishing'."

  validation {
    condition     = contains(["None", "Web", "Publishing", "Web, Publishing"], var.internal_load_balancing_mode)
    error_message = "Possible values are 'None', 'Web', 'Publishing', or 'Web, Publishing'."
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `"CanNotDelete"` and `"ReadOnly"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled. Defaults to `false`.
  - `user_assigned_resource_ids` - (Optional) Specifies a set of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
}

variable "multi_size" {
  type        = string
  default     = null
  description = "Front-end VM size, e.g. 'Medium', 'Large'."
}

variable "private_endpoint_connections" {
  type = map(object({
    name         = optional(string, null)
    ip_addresses = optional(list(string), [])
    private_link_service_connection_state = optional(object({
      actions_required = optional(string, null)
      description      = optional(string, null)
      status           = optional(string, "Approved")
    }), {})
    timeouts = optional(object({
      create = optional(string, "30m")
      delete = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
    }), {})
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of private endpoint connections to create. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the private endpoint connection.
  - `ip_addresses` - (Optional) A list of IP addresses for the private endpoint.
  - `private_link_service_connection_state` - (Optional) The state of the private link service connection.
    - `actions_required` - (Optional) Actions required for the connection.
    - `description` - (Optional) A description of the connection.
    - `status` - (Optional) The status of the connection. Defaults to 'Approved'.
  - `timeouts` - (Optional) Timeouts for the private endpoint connection operations.
    - `create` - (Optional) Timeout for create operations. Defaults to '30m'.
    - `delete` - (Optional) Timeout for delete operations. Defaults to '30m'.
    - `read` - (Optional) Timeout for read operations. Defaults to '5m'.
    - `update` - (Optional) Timeout for update operations. Defaults to '30m'.
  DESCRIPTION
  nullable    = false
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

  - `error_message_regex` - (Optional) A list of regular expressions to match against error messages. If any match, the operation will be retried.
  - `interval_seconds` - (Optional) The initial interval in seconds between retries.
  - `max_interval_seconds` - (Optional) The maximum interval in seconds between retries.
  DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the App Service Environment (ASE). The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "timeouts" {
  type = object({
    create = optional(string, "6h")
    delete = optional(string, "6h")
    read   = optional(string, "5m")
    update = optional(string, "6h")
  })
  default     = {}
  description = <<DESCRIPTION
  Timeouts for resource operations. App Service Environments (ASE) can take a long time to create and update.

  - `create` - (Optional) The timeout for create operations. Defaults to '6h'.
  - `delete` - (Optional) The timeout for delete operations. Defaults to '6h'.
  - `read` - (Optional) The timeout for read operations. Defaults to '5m'.
  - `update` - (Optional) The timeout for update operations. Defaults to '6h'.
  DESCRIPTION
}

variable "tls_1_enabled" {
  type        = bool
  default     = false
  description = "Enable TLS 1.0 on the App Service Environment (ASE): https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings#disable-tls-10-and-tls-11"
}

variable "upgrade_preference" {
  type        = string
  default     = "None"
  description = "Upgrade Preference. Possible values are 'None', 'Early', 'Late', or 'Manual'."

  validation {
    condition     = contains(["None", "Early", "Late", "Manual"], var.upgrade_preference)
    error_message = "Possible values are 'None', 'Early', 'Late', or 'Manual'."
  }
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = true
  description = "Specifies if the App Service Environment (ASE) is zone redundant. Defaults to true. Zonal ASEs can only be deployed in some regions."
}
