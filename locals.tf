locals {
  # Extract subscription ID and virtual network ID from subnet_id
  subnet_id_parts    = split("/", var.subnet_id)
  subscription_id    = local.subnet_id_parts[2]
  virtual_network_id = join("/", slice(local.subnet_id_parts, 0, 9))
}

