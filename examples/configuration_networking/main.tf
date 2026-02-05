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

# Create the ASE first using the main module
module "ase" {
  source = "../../"

  location         = azapi_resource.resource_group.location
  name             = module.naming.app_service_environment.name_unique
  parent_id        = azapi_resource.resource_group.id
  subnet_id        = azapi_resource.subnet.id
  enable_telemetry = var.enable_telemetry
}

# Use the networking configuration submodule to update networking settings
module "networking_configuration" {
  source = "../../modules/configuration_networking"

  hosting_environment_id = module.ase.resource_id
  # Networking settings
  allow_new_private_endpoint_connections = false
  ftp_enabled                            = false
  remote_debug_enabled                   = false
  timeouts = {
    create = "30m"
    delete = "30m"
    read   = "5m"
    update = "30m"
  }
}
