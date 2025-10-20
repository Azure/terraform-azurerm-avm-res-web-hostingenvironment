terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


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

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.location
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_virtual_network" "example_virtual_network" {
  location            = azurerm_resource_group.this.location
  name                = "example_virtual_network"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example_subnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "example_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.example_virtual_network.name

  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  name                = module.naming.app_service_environment.name_unique
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.example_subnet.id
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azurerm_log_analytics_workspace.this.id
      log_analytics_destination_type = "Dedicated"
    }
  }
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  enable_telemetry = var.enable_telemetry # see variables.tf
}
