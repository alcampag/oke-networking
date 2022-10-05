output "vcn_id" {
  value = oci_core_vcn.oke_vcn.id
}

output "api_subnet_id" {
  value = oci_core_subnet.oke_api_subnet.id
}

output "lb_subnet_ids" {
  value = compact(
    [length(oci_core_subnet.oke_public_lb_subnet) == 0 ? "" : oci_core_subnet.oke_public_lb_subnet.0.id,
    length(oci_core_subnet.oke_private_lb_subnet) == 0 ? "" : oci_core_subnet.oke_private_lb_subnet.0.id]
    )
}