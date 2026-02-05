locals {
  # Extract virtual network ID from subnet_id
  subnet_id_parts    = split("/", var.subnet_id)
  virtual_network_id = join("/", slice(local.subnet_id_parts, 0, 9))
}

