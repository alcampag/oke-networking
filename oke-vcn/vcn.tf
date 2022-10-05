
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.vcn_configs.compartment_ocid
  display_name = var.vcn_configs.name
  cidr_blocks = var.vcn_configs.vcn_cidr_blocks
  dns_label = var.vcn_configs.dns_label
}

resource "oci_core_subnet" "oke_api_subnet" {
  cidr_block     = var.vcn_configs.api_subnet_cidr
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.api_subnet_name
  prohibit_public_ip_on_vnic = var.vcn_configs.public_oke_api ? false : true
  route_table_id = oci_core_route_table.api_subnet_route_table.id
  security_list_ids = [oci_core_security_list.oke_api_subnet_sl.id]
}

resource "oci_core_subnet" "oke_nodes_subnet" {
  cidr_block     = var.vcn_configs.nodes_subnet_cidr
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.nodes_subnet_name
  prohibit_public_ip_on_vnic = true
  route_table_id = oci_core_route_table.nodes_subnet_route_table.id
  security_list_ids = [oci_core_security_list.oke_nodes_subnet_sl.id]
}

resource "oci_core_subnet" "oke_public_lb_subnet" {
  cidr_block     = var.vcn_configs.public_lb_subnet_cidr
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.public_lb_subnet_name
  prohibit_public_ip_on_vnic = false
  route_table_id = oci_core_route_table.public_lb_route_table.0.id
  security_list_ids = [oci_core_security_list.oke_public_lb_sl.0.id]
  count = var.vcn_configs.public_lb_subnet_cidr == null ? 0 : 1
}

resource "oci_core_subnet" "oke_private_lb_subnet" {
  cidr_block     = var.vcn_configs.private_lb_subnet_cidr
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.private_lb_subnet_name
  prohibit_public_ip_on_vnic = true
  route_table_id = oci_core_route_table.private_lb_route_table.0.id
  security_list_ids = [oci_core_security_list.oke_private_lb_sl.0.id]
  count = var.vcn_configs.private_lb_subnet_cidr == null ? 0 : 1
}

resource "oci_core_subnet" "oke_pods_subnet" {
  cidr_block     = var.vcn_configs.pods_subnet_configs[count.index].cidr_block
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = var.vcn_configs.pods_subnet_configs[count.index].name
  prohibit_public_ip_on_vnic = true
  route_table_id = oci_core_route_table.pods_route_table[count.index].id
  security_list_ids = [oci_core_security_list.oke_pods_sl[count.index].id]
  count = local.is_native_pod_cni ? length(var.vcn_configs.pods_subnet_configs) : 0
}