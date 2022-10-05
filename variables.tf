variable "tenancy_ocid" {} # (tenancy OCID), already provided on stack and pipeline
variable "compartment_ocid" {} # (compartment OCID), already provided on stack
variable "region" {} # (region), already provided on stack

#variable "config_file_profile" {
#  description = "Config file profile to use"
#  type        = string
#  default = null
#}
#
#variable "LOCAL_ENV" {
#  description = "If true, then we are in a local development environment"
#  type = bool
#  default = true
#}

variable "oke_cluster_name" {
  type = string
  description = "Name of the kubernetes cluster to create."
  default = "my-oke-cluster"
}

variable "oke_vcn_name" {
  type = string
  description = "Name of the oke vcn."
  default = "oke-vcn"
}

variable "oke_cluster_configs" {  # null to create only network
  type = object({
    kubernetes_version = string   #ex: v1.24.1
    cni_type = string           # FLANNEL or OCI_VCN_IP_NATIVE
    is_dashboard_enabled = bool
    is_public_ip_enabled = bool # if false, api server won't have a public ip
  })
}

variable "vcn_configs" {
  type = object({
    dns_label = string    # optional, can be null: https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn#dns_label
    public_oke_api = bool
    vcn_cidr_blocks = list(string)
    api_subnet_cidr = string
    public_lb_subnet_cidr = string    # if null, private_lb_subnet_cidr must be specified
    private_lb_subnet_cidr = string   # if null, public_lb_subnet_cidr must be specified
    nodes_subnet_cidr = string
    api_subnet_allowed_cidr = list(string)    # can be null or empty
    ssh_nodes_subnet_allowed_cidr = list(string)  # can be null or empty
    public_lb_subnet_allowed_cidr = list(string)  # can be null or empty
    private_lb_subnet_allowed_cidr = list(string) # can be null or empty
    pods_subnet_configs = list(object({           # null if planning to create FLANNEL OKE, otherwise a list with at least a CIDR block
      name = string
      cidr_block = string
    }))
  })
}