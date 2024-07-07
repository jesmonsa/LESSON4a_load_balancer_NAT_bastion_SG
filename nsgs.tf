# Web NSG
resource "oci_core_network_security_group" "WebSecurityGroup" {
  compartment_id = oci_identity_compartment.Prod_01.id
  display_name   = "WebSecurityGroup"
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id
}

# Web NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "WebSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Web NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "WebSecurityIngressGroupRules" {
    for_each = toset([for port in var.webservice_ports : tostring(port)])

  network_security_group_id = oci_core_network_security_group.WebSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# SSH NSG
resource "oci_core_network_security_group" "SSHSecurityGroup" {
  compartment_id = oci_identity_compartment.Prod_01.id
  display_name   = "SSHSecurityGroup"
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id
}

# SSH NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "SSHSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSH NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "SSHSecurityIngressGroupRules" {
    for_each = toset([for port in var.bastion_ports : tostring(port)])

  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}