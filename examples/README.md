# Examples

This directory contains examples demonstrating various configurations of the App Service Environment v3 module.

## Available Examples

| Example | Description |
|---------|-------------|
| [default](./default/) | Basic ASE deployment with diagnostic settings |
| [complete](./complete/) | Comprehensive example with all available settings |
| [configuration_networking](./configuration_networking/) | Using the networking configuration submodule |
| [configuration_custom_dns_suffix](./configuration_custom_dns_suffix/) | Configuring a custom DNS suffix with Key Vault certificate |
| [private_endpoint_connection](./private_endpoint_connection/) | Managing private endpoint connections |

## Running Examples

Each example can be deployed independently:

```bash
cd examples/<example_name>
terraform init
terraform plan
terraform apply
```

> **Note:** Examples are deployable and idempotent. Random values are used to ensure unique resource names via the [naming module](https://registry.terraform.io/modules/Azure/naming/azurerm/latest).
