# Worker Pool

This submodule manages worker pools for an App Service Environment using the AzAPI provider.

> **Note:** This resource is primarily used for ASEv1/v2. ASEv3 manages worker pools internally and this resource may not be applicable.

## Features

- Configures worker pool compute mode
- Sets worker count and size
- Supports SKU configuration for scaling
- Supports multiple worker pools (typically named 0, 1, 2)
