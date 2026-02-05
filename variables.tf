variable "location" {
  type        = string
  description = "The Azure region where the App Service Environment will be deployed."
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

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the App Service Environment should be connected to. The subnet must be delegated to Microsoft.Web/hostingEnvironments."
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  default     = true
  description = "Property to enable and disable new private endpoint connection creation on ASE. Defaults to true."
}

variable "cluster_settings" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = null
  description = "Custom settings for changing the behavior of the App Service Environment. These settings are stored in the clusterSettings attribute of the hostingEnvironments Azure Resource Manager entity."
}

variable "custom_dns_suffix_configuration" {
  type = object({
    kind                         = optional(string, null)
    certificate_url              = string
    dns_suffix                   = string
    key_vault_reference_identity = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Full view of the custom domain suffix configuration for ASEv3. The following properties can be specified:

  - `kind` - (Optional) Kind of resource.
  - `certificate_url` - (Required) The URL referencing the Azure Key Vault certificate secret that should be used as the default SSL/TLS certificate for sites with the custom domain suffix.
  - `dns_suffix` - (Required) The default custom domain suffix to use for all sites deployed on the ASE.
  - `key_vault_reference_identity` - (Optional) The user-assigned identity to use for resolving the key vault certificate reference. If not specified, the system-assigned ASE identity will be used if available.
  DESCRIPTION
}

variable "dedicated_host_count" {
  type        = number
  default     = null
  description = "Dedicated Host Count for this ASEv3. Possible value is 2. Setting this value will make the ASE use dedicated hosts."

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
  A map of diagnostic settings to create on the App Service Environment. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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

variable "dns_suffix" {
  type        = string
  default     = null
  description = "DNS suffix of the App Service Environment."
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

variable "front_end_scale_factor" {
  type        = number
  default     = null
  description = "Scale factor for front-ends. Must be between 5 and 15."

  validation {
    condition     = var.front_end_scale_factor == null || (var.front_end_scale_factor >= 5 && var.front_end_scale_factor <= 15)
    error_message = "The front_end_scale_factor must be null or between 5 and 15."
  }
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

variable "internal_load_balancing_mode" {
  type        = string
  default     = "None"
  description = "Specifies which endpoints to serve internally in the Virtual Network for the App Service Environment. Possible values are 'None', 'Web', 'Publishing', or 'Web, Publishing'."

  validation {
    condition     = contains(["None", "Web", "Publishing", "Web, Publishing"], var.internal_load_balancing_mode)
    error_message = "Possible values are 'None', 'Web', 'Publishing', or 'Web, Publishing'."
  }
}

variable "ipssl_address_count" {
  type        = number
  default     = null
  description = "Number of IP SSL addresses reserved for the App Service Environment."
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
  description = "Property to enable and disable Remote Debug on ASEV3."
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), null)
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
    multiplier           = optional(number, 1.5)
    randomization_factor = optional(number, 0.5)
  })
  default     = null
  description = <<DESCRIPTION
  Retry configuration for transient errors. If not specified, no retries will be attempted.

  - `error_message_regex` - (Optional) A list of regular expressions to match against error messages. If any match, the operation will be retried.
  - `interval_seconds` - (Optional) The initial interval in seconds between retries. Defaults to 10.
  - `max_interval_seconds` - (Optional) The maximum interval in seconds between retries. Defaults to 180.
  - `multiplier` - (Optional) The multiplier for exponential backoff. Defaults to 1.5.
  - `randomization_factor` - (Optional) The randomization factor for jitter. Defaults to 0.5.
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
  A map of role assignments to create on the App Service Environment. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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

variable "subnet_name" {
  type        = string
  default     = null
  description = "Subnet name within the Virtual Network. This is extracted from subnet_id if not provided."
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
  Timeouts for resource operations. App Service Environments can take a long time to create and update.

  - `create` - (Optional) The timeout for create operations. Defaults to '6h'.
  - `delete` - (Optional) The timeout for delete operations. Defaults to '6h'.
  - `read` - (Optional) The timeout for read operations. Defaults to '5m'.
  - `update` - (Optional) The timeout for update operations. Defaults to '6h'.
  DESCRIPTION
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

variable "user_whitelisted_ip_ranges" {
  type        = list(string)
  default     = null
  description = "User added IP ranges to whitelist on ASE database."
}

variable "zone_redundant" {
  type        = bool
  default     = true
  description = "Specifies if the App Service Environment is zone redundant. Defaults to true. Zonal ASEs can only be deployed in some regions."
}
