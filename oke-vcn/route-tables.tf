resource "oci_core_route_table" "api_subnet_route_table" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.api_subnet_name}-rt"
  dynamic "route_rules" {
    for_each = var.vcn_configs.public_oke_api ? [] : [0]  # Rules if private api subnet
    content {
      network_entity_id = oci_core_service_gateway.ServGateway.id
      destination = data.oci_core_services.getServices.services.0.cidr_block
      destination_type = "SERVICE_CIDR_BLOCK"
      description = "Route rule to enable communication with OCI services, including Kubernetes control plane"
    }
  }
  dynamic "route_rules" {
    for_each = var.vcn_configs.public_oke_api ? [] : [0] # Rules if private api subnet
    content {
      network_entity_id = oci_core_nat_gateway.NATGateway.id
      description = "Route rule to redirect all traffic to NAT gateway"
      destination_type = "CIDR_BLOCK"
      destination = "0.0.0.0/0"
    }
  }
  dynamic "route_rules" {
    for_each = var.vcn_configs.public_oke_api ? [0] : [] # Rules if public api subnet
    content {
      network_entity_id = oci_core_internet_gateway.IGateway.id
      destination_type = "CIDR_BLOCK"
      description = "Route rule to redirect all traffic to Internet gateway"
      destination = "0.0.0.0/0"
    }
  }
}

resource "oci_core_route_table" "nodes_subnet_route_table" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.nodes_subnet_name}-rt"
  route_rules {
    network_entity_id = oci_core_service_gateway.ServGateway.id
    destination = data.oci_core_services.getServices.services.0.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Route rule to enable communication with OCI services, including Kubernetes control plane"
  }
  route_rules {
    network_entity_id = oci_core_nat_gateway.NATGateway.id
    description = "Route rule to redirect all traffic to NAT gateway"
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_route_table" "public_lb_route_table" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.public_lb_subnet_name}-rt"
  route_rules {
    network_entity_id = oci_core_internet_gateway.IGateway.id
    destination_type = "CIDR_BLOCK"
    description = "Route rule to redirect all traffic to Internet gateway"
    destination = "0.0.0.0/0"
  }
  count = var.vcn_configs.public_lb_subnet_cidr == null ? 0 : 1
}

resource "oci_core_route_table" "private_lb_route_table" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.private_lb_subnet_name}-rt"
  count = var.vcn_configs.private_lb_subnet_cidr == null ? 0 : 1
}

resource "oci_core_route_table" "pods_route_table" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${var.vcn_configs.pods_subnet_configs[count.index].name}-rt"
  route_rules {
    network_entity_id = oci_core_service_gateway.ServGateway.id
    destination = data.oci_core_services.getServices.services.0.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Route rule to enable communication with OCI services, including Kubernetes control plane"
  }
  route_rules {
    network_entity_id = oci_core_nat_gateway.NATGateway.id
    description = "Route rule to redirect all traffic to NAT gateway"
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
  count = local.is_native_pod_cni ? length(var.vcn_configs.pods_subnet_configs) : 0
}