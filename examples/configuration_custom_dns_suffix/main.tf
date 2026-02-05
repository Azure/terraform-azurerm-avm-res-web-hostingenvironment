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
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
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
  dns_suffix = "internal.contoso.com"
  location   = local.locations[random_integer.region_index.result]
}

# Get current client configuration for Key Vault access
data "azurerm_client_config" "current" {}

# Resource Group using AzAPI
resource "azapi_resource" "resource_group" {
  location = local.location
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

# Key Vault for storing the certificate
resource "azurerm_key_vault" "this" {
  location                   = local.location
  name                       = module.naming.key_vault.name_unique
  resource_group_name        = azapi_resource.resource_group.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  access_policy {
    certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update",
    ]
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
    ]
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
}

# Self-signed certificate for the custom DNS suffix
resource "azurerm_key_vault_certificate" "this" {
  key_vault_id = azurerm_key_vault.this.id
  name         = "ase-custom-domain-cert"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_type   = "RSA"
      reuse_key  = true
      key_size   = 2048
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }
    x509_certificate_properties {
      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]
      subject            = "CN=*.${local.dns_suffix}"
      validity_in_months = 12
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      subject_alternative_names {
        dns_names = [
          "*.${local.dns_suffix}",
          "*.scm.${local.dns_suffix}",
        ]
      }
    }
  }
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

  location                     = azapi_resource.resource_group.location
  name                         = module.naming.app_service_environment.name_unique
  parent_id                    = azapi_resource.resource_group.id
  subnet_id                    = azapi_resource.subnet.id
  enable_telemetry             = var.enable_telemetry
  internal_load_balancing_mode = "Web, Publishing"
}

# Use the custom DNS suffix configuration submodule
module "custom_dns_suffix" {
  source = "../../modules/configuration_custom_dns_suffix"

  certificate_url        = azurerm_key_vault_certificate.this.secret_id
  dns_suffix             = local.dns_suffix
  hosting_environment_id = module.ase.resource_id
  timeouts = {
    create = "30m"
    delete = "30m"
    read   = "5m"
    update = "30m"
  }
}
