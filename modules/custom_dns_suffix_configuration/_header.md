# Custom DNS Suffix Configuration Sub-module

This sub-module configures a custom DNS suffix for an App Service Environment (ASE) using the `Microsoft.Web/hostingEnvironments/configurations` API with the `customdnssuffix` configuration name.

This property is read-only at ASE create time and must be applied separately via an update.
