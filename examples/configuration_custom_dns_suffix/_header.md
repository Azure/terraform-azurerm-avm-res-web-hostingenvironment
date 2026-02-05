# Configuration Custom DNS Suffix Example

This example demonstrates the use of the `configuration_custom_dns_suffix` submodule to configure a custom DNS suffix on an existing App Service Environment v3.

The example includes:

- Creating a Key Vault with a self-signed certificate
- Creating an ASE with internal load balancing
- Configuring the custom DNS suffix using the submodule

## Prerequisites

For production use, you should:

1. Use a certificate from a trusted Certificate Authority
2. Configure proper DNS records for the custom domain
3. Grant the ASE managed identity access to the Key Vault certificate
