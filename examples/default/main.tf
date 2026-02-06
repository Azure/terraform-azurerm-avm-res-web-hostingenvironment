terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
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
# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.locations) - 1
  min = 0
}

## End of section to provide a random Azure region for the resource group

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

moved {
  from = azurerm_resource_group.this
  to   = azapi_resource.resource_group
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

moved {
  from = azurerm_log_analytics_workspace.this
  to   = azapi_resource.log_analytics_workspace
}

# Virtual Network using AzAPI
resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = "example_virtual_network"
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

moved {
  from = azurerm_virtual_network.example_virtual_network
  to   = azapi_resource.virtual_network
}

# Subnet using AzAPI with delegation to App Service Environment
resource "azapi_resource" "subnet" {
  name      = "example_subnet"
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  body = {
    properties = {
      addressPrefix = "10.0.1.0/24"
      delegations = [
        {
          name = "example-delegation"
          properties = {
            serviceName = "Microsoft.Web/hostingEnvironments"
          }
        }
      ]
    }
  }
  response_export_values = ["*"]
}

moved {
  from = azurerm_subnet.example_subnet
  to   = azapi_resource.subnet
}

# This is the module call
module "test" {
  source = "../../"

  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_environment.name_unique
  parent_id = azapi_resource.resource_group.id
  subnet_id = azapi_resource.subnet.id
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azapi_resource.log_analytics_workspace.id
      log_analytics_destination_type = "Dedicated"
    }
  }
  enable_telemetry = var.enable_telemetry # see variables.tf
  managed_identities = {
    system_assigned = true
  }
}
