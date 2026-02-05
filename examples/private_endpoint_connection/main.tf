terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
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

# ASE Subnet using AzAPI with delegation to App Service Environment
resource "azapi_resource" "ase_subnet" {
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

# Private Endpoint Subnet
resource "azapi_resource" "pe_subnet" {
  name      = "pe-subnet"
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  body = {
    properties = {
      addressPrefix = "10.0.2.0/24"
    }
  }
  response_export_values = ["*"]

  depends_on = [azapi_resource.ase_subnet]
}

# Create the ASE using the main module with private endpoint connections enabled
module "ase" {
  source = "../../"

  location                               = azapi_resource.resource_group.location
  name                                   = module.naming.app_service_environment.name_unique
  parent_id                              = azapi_resource.resource_group.id
  subnet_id                              = azapi_resource.ase_subnet.id
  allow_new_private_endpoint_connections = true
  enable_telemetry                       = var.enable_telemetry
  internal_load_balancing_mode           = "Web, Publishing"
  # Define private endpoint connections through the main module
  private_endpoint_connections = {
    pe1 = {
      name = "approved-pe-connection"
      private_link_service_connection_state = {
        status      = "Approved"
        description = "Approved via Terraform"
      }
    }
  }
}

# Alternatively, use the private endpoint connection submodule directly
# This is useful when you need to manage connections separately from the ASE
module "private_endpoint_connection" {
  source = "../../modules/private_endpoint_connection"

  hosting_environment_id = module.ase.resource_id
  name                   = "standalone-pe-connection"
  private_link_service_connection_state = {
    status           = "Approved"
    description      = "Managed by separate submodule"
    actions_required = "None"
  }
  timeouts = {
    create = "30m"
    delete = "30m"
    read   = "5m"
    update = "30m"
  }
}
