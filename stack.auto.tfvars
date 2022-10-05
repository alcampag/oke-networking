vcn_configs = {
  dns_label = "oke"
  public_oke_api = true
  vcn_cidr_blocks = ["10.0.0.0/16"]
  api_subnet_cidr = "10.0.255.248/30"
  public_lb_subnet_cidr = "10.0.248.0/22"
  private_lb_subnet_cidr = null
  nodes_subnet_cidr = "10.0.224.0/20"
  api_subnet_allowed_cidr = ["0.0.0.0/0"]
  ssh_nodes_subnet_allowed_cidr = null
  public_lb_subnet_allowed_cidr = ["0.0.0.0/0"]
  private_lb_subnet_allowed_cidr = null
  pods_subnet_configs = [{
    name = "pods"
    cidr_block = "10.0.192.0/19"
  }]
}

oke_cluster_configs = {
  kubernetes_version = "v1.24.1"
  cni_type = "OCI_VCN_IP_NATIVE"  # FLANNEL or OCI_VCN_IP_NATIVE
  is_dashboard_enabled = true
  is_public_ip_enabled = true
}
