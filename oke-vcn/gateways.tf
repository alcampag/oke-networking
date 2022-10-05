# Internet Gateway for public subnet
resource "oci_core_internet_gateway" "IGateway" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.ig_name
  enabled = true
}

# NAT Gateway for private worker nodes
resource "oci_core_nat_gateway" "NATGateway" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.nat_name
}

# Since worker nodes and API server are in a private network, to communicate between them we need a Service Gateway

resource "oci_core_service_gateway" "ServGateway" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = local.sg_name
  services {
    service_id = data.oci_core_services.getServices.services.0.id
  }
}