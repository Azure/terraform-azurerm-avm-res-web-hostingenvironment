locals {
  # Parse subnet_id using azapi provider function
  parsed_subnet_id   = provider::azapi::parse_resource_id("Microsoft.Network/virtualNetworks/subnets", var.subnet_id)
  subnet_name        = local.parsed_subnet_id.name
  virtual_network_id = local.parsed_subnet_id.parent_id
}
