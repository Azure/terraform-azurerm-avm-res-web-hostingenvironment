# Private Endpoint Connection Example

This example demonstrates two approaches for managing private endpoint connections on an App Service Environment (ASE):

1. **Using the main module** - Define private endpoint connections directly in the `private_endpoint_connections` variable
2. **Using the submodule** - Use the `private_endpoint_connection` submodule for standalone management

## Use Cases

- Use the main module approach when managing connections as part of the ASE lifecycle
- Use the submodule approach when:
  - Managing connections separately from the ASE
  - Approving/rejecting connections created by external private endpoints
  - Fine-grained control over connection lifecycle
