terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
locals {
  locations = [
    "eastus",
    "eastus2",
    "westus2",
    "centralus",
    "westeurope",
    "northeurope",
    "southeastasia",
    "japaneast",
  ]
}

resource "random_integer" "region_index" {
  max = length(local.locations) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

locals {
  location = local.locations[random_integer.region_index.result]
}

# Resource Group using AzAPI
resource "azapi_resource" "resource_group" {
  location = local.location
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

# Log Analytics Workspace using AzAPI
resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.log_analytics_workspace.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
      retentionInDays = 30
    }
  }
  response_export_values = ["*"]
}

# Virtual Network using AzAPI
resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2024-01-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/16"]
      }
    }
  }
  response_export_values = ["*"]
}

# Subnet using AzAPI with delegation to App Service Environment
resource "azapi_resource" "subnet" {
  name      = "ase-subnet"
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  body = {
    properties = {
      addressPrefix = "10.0.1.0/24"
      delegations = [
        {
          name = "ase-delegation"
          properties = {
            serviceName = "Microsoft.Web/hostingEnvironments"
          }
        }
      ]
    }
  }
  response_export_values = ["*"]
}

# Get current user/service principal for role assignment
data "azurerm_client_config" "current" {}

# This is the module call with all available settings
module "test" {
  source = "../../"

  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_environment.name_unique
  parent_id = azapi_resource.resource_group.id
  subnet_id = azapi_resource.subnet.id
  # Networking configuration
  allow_new_private_endpoint_connections = true
  # Cluster settings
  cluster_settings = [
    {
      name  = "DisableTls1.0"
      value = "1"
    },
    {
      name  = "InternalEncryption"
      value = "true"
    }
  ]
  # Diagnostic settings
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azapi_resource.log_analytics_workspace.id
      log_analytics_destination_type = "Dedicated"
      log_groups                     = ["allLogs"]
      metric_categories              = ["AllMetrics"]
    }
  }
  enable_telemetry = var.enable_telemetry
  # Front-end configuration
  ftp_enabled                  = false
  internal_load_balancing_mode = "Web, Publishing"
  # Resource lock
  lock = {
    kind = "CanNotDelete"
    name = "ase-lock"
  }
  remote_debug_enabled = false
  # Retry configuration
  retry = {
    error_message_regex  = ["InternalServerError", "ServiceUnavailable"]
    interval_seconds     = 10
    max_interval_seconds = 300
  }
  # Role assignments
  role_assignments = {
    reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azurerm_client_config.current.object_id
      principal_type             = "ServicePrincipal"
    }
  }
  # Tags
  tags = {
    Environment = "Production"
    CostCenter  = "IT"
    Project     = "ASE-Complete"
  }
  # Timeouts
  timeouts = {
    create = "6h"
    delete = "6h"
    read   = "5m"
    update = "6h"
  }
  # Upgrade preference
  upgrade_preference = "Early"
  # Zone redundancy
  zone_redundancy_enabled = true
}
