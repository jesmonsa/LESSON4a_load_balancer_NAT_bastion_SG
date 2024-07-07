# VCN
resource "oci_core_virtual_network" "VCN_Prod_01" { # definir el recurso de la red virtual (VCN)
  cidr_block     = var.VCN-CIDR # definir el bloque CIDR de la VCN
  dns_label      = "vcnprod01" # definir la etiqueta DNS de la VCN
  compartment_id = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  display_name   = "vcnprod01" # definir el nombre de la VCN
}

# DHCP Options
resource "oci_core_dhcp_options" "DhcpOptions1" { # definir el recurso de las opciones DHCP
  compartment_id = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id # definir el OCID de la VCN
  display_name   = "DHCPOptions1"

  options {
    type        = "DomainNameServer" # definir el tipo de opción
    server_type = "VcnLocalPlusInternet" # definir el tipo de servidor
  }

  options {
    type                = "SearchDomain"  # definir el tipo de opción
    search_domain_names = ["example.com"] # definir el nombre del dominio de búsqueda
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "InternetGateway" { # definir el recurso de la puerta de enlace de Internet
  compartment_id = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  display_name   = "InternetGateway" # definir el nombre de la puerta de enlace de Internet
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id # definir el OCID de la VCN
}

# Route Table for IGW
resource "oci_core_route_table" "RouteTableViaIGW" { # definir el recurso de la tabla de rutas
  compartment_id = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id # definir el OCID de la VCN
  display_name   = "RouteTableViaIGW"
  route_rules { # definir las reglas de ruta
    destination       = "0.0.0.0/0" # definir el destino
    destination_type  = "CIDR_BLOCK" # definir el tipo de destino
    network_entity_id = oci_core_internet_gateway.InternetGateway.id # definir el OCID de la puerta de enlace de Internet
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "NATGateway" {
  compartment_id = oci_identity_compartment.Prod_01.id
  display_name   = "NATGateway"
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id
}

# Route Table for NAT
resource "oci_core_route_table" "RouteTableViaNAT" {
  compartment_id = oci_identity_compartment.Prod_01.id
  vcn_id         = oci_core_virtual_network.VCN_Prod_01.id
  display_name   = "RouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NATGateway.id
  }
}

# WebSubnet (private)
resource "oci_core_subnet" "WebSubnet" { # definir el recurso de la subred
  cidr_block        = var.WebSubnet-CIDR # definir el bloque CIDR de la subred
  display_name      = "WebSubnet" # definir el nombre de la subred
  dns_label         = "WebSubnetN1"   # definir la etiqueta DNS de la subred
  compartment_id    = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  vcn_id            = oci_core_virtual_network.VCN_Prod_01.id # definir el OCID de la VCN
  route_table_id    = oci_core_route_table.RouteTableViaNAT.id # definir el OCID de la tabla de rutas
  dhcp_options_id   = oci_core_dhcp_options.DhcpOptions1.id # definir el OCID de las opciones DHCP
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "LBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "LBSubnet"
  dns_label         = "LBSubnet"
  compartment_id    = oci_identity_compartment.Prod_01.id
  vcn_id            = oci_core_virtual_network.VCN_Prod_01.id
  route_table_id    = oci_core_route_table.RouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.DhcpOptions1.id
  
}

# Bastion Subnet (public)
resource "oci_core_subnet" "BastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "BastionSubnet"
  dns_label         = "BastionSubnet"
  compartment_id    = oci_identity_compartment.Prod_01.id
  vcn_id            = oci_core_virtual_network.VCN_Prod_01.id
  route_table_id    = oci_core_route_table.RouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.DhcpOptions1.id
  
}