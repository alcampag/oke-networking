terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "4.94.0"
    }
  }
}

provider "oci" {
  region = var.region
  config_file_profile = var.LOCAL_ENV ? var.config_file_profile : null
}