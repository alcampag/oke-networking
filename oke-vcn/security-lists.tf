
resource "oci_core_security_list" "oke_api_subnet_sl" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.api_subnet_name}-sl"
  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.vcn_configs.nodes_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Kubernetes worker to Kubernetes API endpoint communication."
    stateless = false
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.vcn_configs.nodes_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Kubernetes worker to Kubernetes API endpoint communication."
    stateless = false
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  ingress_security_rules {
    protocol = local.icmp_protocol
    source   = var.vcn_configs.nodes_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Path Discovery."
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  dynamic "ingress_security_rules" {
    for_each = local.is_native_pod_cni ? var.vcn_configs.pods_subnet_configs : []
    iterator = pods_config
    content {
      protocol = local.tcp_protocol
      source = pods_config.value.cidr_block
      source_type = "CIDR_BLOCK"
      description = "Pod subnet (${pods_config.value.name}) to Kubernetes API endpoint communication."
      stateless = false
      tcp_options {
        max = "6443"
        min = "6443"
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = local.is_native_pod_cni ? var.vcn_configs.pods_subnet_configs : []
    iterator = pods_config
    content {
      protocol = local.tcp_protocol
      source = pods_config.value.cidr_block
      source_type = "CIDR_BLOCK"
      description = "Pod subnet (${pods_config.value.name}) to Kubernetes API endpoint communication."
      stateless = false
      tcp_options {
        max = "12250"
        min = "12250"
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = var.vcn_configs.api_subnet_allowed_cidr != null ? var.vcn_configs.api_subnet_allowed_cidr : []
    iterator = allowed_cidr
    content {
      protocol = local.tcp_protocol
      source = allowed_cidr.value
      source_type = "CIDR_BLOCK"
      description = "Client access to Kubernetes API endpoint."
      stateless = false
      tcp_options {
        max = "6443"
        min = "6443"
      }
    }
  }
  egress_security_rules {
    destination = data.oci_core_services.getServices.services.0.cidr_block
    protocol    = local.tcp_protocol
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Allow Kubernetes API endpoint to communicate with OKE."
    stateless = false
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    destination = var.vcn_configs.nodes_subnet_cidr
    protocol    = local.icmp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Path Discovery."
    icmp_options {
      type = 3
      code = 4
    }
  }
  dynamic "egress_security_rules" {
    for_each = local.is_native_pod_cni ? [] : [0] # Only when using Flannel as CNI
    content {
      destination = var.vcn_configs.nodes_subnet_cidr
      protocol = local.tcp_protocol
      destination_type = "CIDR_BLOCK"
      description = "All traffic to worker nodes (when using flannel for pod networking)."
      stateless = false
    }
  }
  dynamic "egress_security_rules" {
    for_each = local.is_native_pod_cni ? var.vcn_configs.pods_subnet_configs : []
    iterator = pods_config
    content {
      destination = pods_config.value.cidr_block
      protocol = local.tcp_protocol
      destination_type = "CIDR_BLOCK"
      description = "Kubernetes API endpoint to pod communication (${pods_config.value.name})."
      stateless = false
    }
  }
  dynamic "egress_security_rules" {
    for_each = local.is_native_pod_cni ? [0] : []
    content {
      destination = var.vcn_configs.nodes_subnet_cidr
      protocol = local.tcp_protocol
      destination_type = "CIDR_BLOCK"
      description = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)."
      stateless = false
      tcp_options {
        max = "10250"
        min = "10250"
      }
    }
  }
  dynamic "egress_security_rules" {
    for_each = local.is_native_pod_cni ? [0] : []
    content {
      destination = var.vcn_configs.nodes_subnet_cidr
      protocol = local.icmp_protocol
      destination_type = "CIDR_BLOCK"
      description = "Allow ICMP traffic for path discovery to worker nodes (when using VCN-native pod networking)."
      stateless = false
    }
  }
}

resource "oci_core_security_list" "oke_nodes_subnet_sl" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.nodes_subnet_name}-sl"
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_configs.nodes_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Allows communication from (or to) worker nodes."
    stateless = false
  }
  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.vcn_configs.api_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow Kubernetes API endpoint to communicate with worker nodes."
    stateless = false
  }
  ingress_security_rules {
    protocol = local.icmp_protocol
    source   = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "Path Discovery."
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  dynamic "ingress_security_rules" {
    for_each = var.vcn_configs.ssh_nodes_subnet_allowed_cidr != null ? var.vcn_configs.ssh_nodes_subnet_allowed_cidr : []
    iterator = ssh_cidr
    content {
      protocol = local.tcp_protocol
      source = ssh_cidr.value
      source_type = "CIDR_BLOCK"
      description = "Allow inbound SSH traffic to worker nodes."
      stateless = false
      tcp_options {
        min = "22"
        max = "22"
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = local.is_native_pod_cni ? var.vcn_configs.pods_subnet_configs : []
    iterator = pods_config
    content {
      protocol = "all"
      source = pods_config.value.cidr_block
      source_type = "CIDR_BLOCK"
      description = "Allow pods on one worker node to communicate with pods on other worker nodes (when using VCN-native pod networking)."
      stateless = false
    }
  }
  dynamic "ingress_security_rules" {
    for_each = local.is_native_pod_cni ? [0] : []
    content {
      protocol = local.tcp_protocol
      source = var.vcn_configs.api_subnet_cidr
      source_type = "CIDR_BLOCK"
      description = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)."
      stateless = false
      tcp_options {
        max = "12250"
        min = "12250"
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = local.is_native_pod_cni ? [0] : []
    content {
      protocol = local.icmp_protocol
      source = var.vcn_configs.api_subnet_cidr
      source_type = "CIDR_BLOCK"
      description = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)."
      stateless = false
    }
  }
  egress_security_rules {
    destination = var.vcn_configs.nodes_subnet_cidr
    protocol    = "all"
    destination_type = "CIDR_BLOCK"
    description = "Allows communication from (or to) worker nodes."
    stateless = false
  }
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = local.icmp_protocol
    destination_type = "CIDR_BLOCK"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  egress_security_rules {
    destination = data.oci_core_services.getServices.services.0.cidr_block
    protocol    = local.tcp_protocol
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Allow nodes to communicate with OKE."
    stateless = false
  }
  egress_security_rules {
    destination = var.vcn_configs.api_subnet_cidr
    protocol    = local.tcp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Kubernetes worker to Kubernetes API endpoint communication."
    stateless = false
    tcp_options {
      min = "6443"
      max = "6443"
    }
  }
  egress_security_rules {
    destination = var.vcn_configs.api_subnet_cidr
    protocol    = local.tcp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Kubernetes worker to Kubernetes API endpoint communication."
    stateless = false
    tcp_options {
      min = "12250"
      max = "12250"
    }
  }
  dynamic "egress_security_rules" {
    for_each = local.is_native_pod_cni ? var.vcn_configs.pods_subnet_configs : []
    iterator = pods_config
    content {
      destination = pods_config.value.cidr_block
      protocol = "all"
      destination_type = "CIDR_BLOCK"
      description = "Allow worker nodes to communicate with pods on other worker nodes (when using VCN-native pod networking)."
      stateless = false
    }
  }
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = local.tcp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Allow worker nodes to communicate with internet."
    stateless = false
  }
}

resource "oci_core_security_list" "oke_public_lb_sl" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.public_lb_subnet_name}-sl"
  dynamic "ingress_security_rules" {
    for_each = var.vcn_configs.public_lb_subnet_allowed_cidr != null ? var.vcn_configs.public_lb_subnet_allowed_cidr : []
    iterator = allowed_cidr
    content {
      source = allowed_cidr.value
      protocol = local.tcp_protocol
      source_type = "CIDR_BLOCK"
      description = "Allow inbound traffic to Load Balancer."
      stateless = false
      tcp_options {
        min = "443"
        max = "443"
      }
    }
  }
  egress_security_rules {
    protocol = local.tcp_protocol
    destination = var.vcn_configs.nodes_subnet_cidr
    destination_type = "CIDR_BLOCK"
    description = "Allow traffic to worker nodes."
    stateless = false
    tcp_options {
      min = "30000"
      max = "32767"
    }
  }
  count = var.vcn_configs.public_lb_subnet_cidr == null ? 0 : 1
}

resource "oci_core_security_list" "oke_private_lb_sl" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${local.private_lb_subnet_name}-sl"
  dynamic "ingress_security_rules" {
    for_each = var.vcn_configs.private_lb_subnet_allowed_cidr != null ? var.vcn_configs.private_lb_subnet_allowed_cidr : []
    iterator = allowed_cidr
    content {
      source = allowed_cidr.value
      protocol = local.tcp_protocol
      source_type = "CIDR_BLOCK"
      description = "Allow inbound traffic to Load Balancer."
      stateless = false
      tcp_options {
        min = "443"
        max = "443"
      }
    }
  }
  egress_security_rules {
    protocol = local.tcp_protocol
    destination = var.vcn_configs.nodes_subnet_cidr
    destination_type = "CIDR_BLOCK"
    description = "Allow traffic to worker nodes."
    stateless = false
    tcp_options {
      min = "30000"
      max = "32767"
    }
  }
  count = var.vcn_configs.private_lb_subnet_cidr == null ? 0 : 1
}

resource "oci_core_security_list" "oke_pods_sl" {
  compartment_id = oci_core_vcn.oke_vcn.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name = "${var.vcn_configs.pods_subnet_configs[count.index].name}-sl"
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_configs.api_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Kubernetes API endpoint to pod communication"
    stateless = false
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_configs.nodes_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow pods on one worker node to communicate with pods on other worker nodes."
    stateless = false
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_configs.pods_subnet_configs[count.index].cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow pods to communicate with each other."
    stateless = false
  }
  egress_security_rules {
    destination = var.vcn_configs.pods_subnet_configs[count.index].cidr_block
    protocol    = "all"
    destination_type = "CIDR_BLOCK"
    description = "Allow pods to communicate with each other."
    stateless = false
  }
  egress_security_rules {
    destination = data.oci_core_services.getServices.services.0.cidr_block
    protocol    = local.icmp_protocol
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Path Discovery."
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  egress_security_rules {
    destination = data.oci_core_services.getServices.services.0.cidr_block
    protocol    = local.tcp_protocol
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Allow pods to communicate with OCI services."
    stateless = false
  }
  egress_security_rules {
    destination = var.vcn_configs.api_subnet_cidr
    protocol    = local.tcp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Pod to Kubernetes API endpoint communication."
    stateless = false
    tcp_options {
      min = "6443"
      max = "6443"
    }
  }
  egress_security_rules {
    destination = var.vcn_configs.api_subnet_cidr
    protocol    = local.tcp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Pod to Kubernetes API endpoint communication."
    stateless = false
    tcp_options {
      min = "12250"
      max = "12250"
    }
  }
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = local.tcp_protocol
    destination_type = "CIDR_BLOCK"
    description = "Allow pods to communicate with Internet."
    stateless = false
  }
  count = local.is_native_pod_cni ? length(var.vcn_configs.pods_subnet_configs) : 0
}