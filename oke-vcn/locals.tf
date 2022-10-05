locals {
  sg_name = "ServGateway"
  nat_name = "NATGateway"
  ig_name = "IGateway"
  api_subnet_name = "api"
  nodes_subnet_name = "nodes"
  public_lb_subnet_name = "public-lb"
  private_lb_subnet_name = "private-lb"
  tcp_protocol = "6"
  icmp_protocol = "1"
  is_native_pod_cni = var.vcn_configs.pods_subnet_configs != null ? true : false
}