locals {
  vcn_configs = merge(var.vcn_configs, {compartment_ocid = var.compartment_ocid, name = var.oke_vcn_name})
}

module "oke-vcn" {
  source = "./oke-vcn"
  vcn_configs = local.vcn_configs
}

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.oke_cluster_configs.kubernetes_version
  name               = var.oke_cluster_name
  vcn_id             = module.oke-vcn.vcn_id

  cluster_pod_network_options {
    cni_type = var.oke_cluster_configs.cni_type
  }

  endpoint_config {
    is_public_ip_enabled = var.oke_cluster_configs.is_public_ip_enabled
    subnet_id = module.oke-vcn.api_subnet_id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.oke_cluster_configs.is_dashboard_enabled
    }
    service_lb_subnet_ids = module.oke-vcn.lb_subnet_ids
  }
  count = var.oke_cluster_configs != null ? 1 : 0
}
