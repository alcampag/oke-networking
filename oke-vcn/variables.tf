variable "vcn_configs" {
  type = object({
    compartment_ocid = string
    name = string
    dns_label = string
    public_oke_api = bool
    vcn_cidr_blocks = list(string)
    api_subnet_cidr = string
    public_lb_subnet_cidr = string
    private_lb_subnet_cidr = string
    nodes_subnet_cidr = string
    api_subnet_allowed_cidr = list(string)
    ssh_nodes_subnet_allowed_cidr = list(string)
    public_lb_subnet_allowed_cidr = list(string)
    private_lb_subnet_allowed_cidr = list(string)
    pods_subnet_configs = list(object({
      name = string
      cidr_block = string
    }))
  })
}