locals {
  fips_mode_cluster_setting = var.fips_mode_enabled ? [{
    name  = "LinuxFipsModeEnabled"
    value = "Enabled"
  }] : []
  internal_encryption_cluster_setting = var.internal_encryption_enabled ? [{
    name  = "InternalEncryption"
    value = "true"
  }] : []
  tls_1_cluster_setting = var.tls_1_enabled ? [] : [{
    name  = "DisableTls1.0"
    value = "1"
  }]
  tls_cipher_suite_order_cluster_setting = var.front_end_tls_cipher_suite_order != null ? [{
    name  = "FrontEndSSLCipherSuiteOrder"
    value = var.front_end_tls_cipher_suite_order
  }] : []
}

locals {
  cluster_settings = concat(var.cluster_settings, local.internal_encryption_cluster_setting, local.tls_1_cluster_setting, local.tls_cipher_suite_order_cluster_setting, local.fips_mode_cluster_setting)
}

locals {
  managed_identities = {
    system_assigned            = var.managed_identities.system_assigned
    user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
    type = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : (
      var.managed_identities.system_assigned ? "SystemAssigned" : (
        length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : null
      )
    )
  }
}
