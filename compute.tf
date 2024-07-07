# Bastion Compute

resource "oci_core_instance" "BastionServer" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.Prod_01.id
  display_name        = "BastionServer"
  shape               = var.Shape
  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-1"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.BastionSubnet.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.SSHSecurityGroup.id]
  }
}

# WebServer1 Compute # 1

resource "oci_core_instance" "Webserver1" { # definir el recurso de la instancia
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name # definir el dominio de disponibilidad de la instancia en caso de que no se haya definido en las variables
  compartment_id      = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  display_name        = "WebServer1" # definir el nombre de la instancia
  shape               = var.Shape # definir la forma de la instancia

  dynamic "shape_config" { # definir la configuración de la forma de la instancia
    for_each = local.is_flexible_shape ? [1] : []  # definir si la forma de la instancia es flexible o no lo es 
    content { # definir el contenido de la forma de la instancia
      memory_in_gbs = var.FlexShapeMemory # definir la memoria de la instancia flexible
      ocpus         = var.FlexShapeOCPUS # definir los OCPUs de la instancia flexible
    }
  }
  fault_domain = "FAULT-DOMAIN-1"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }

  metadata = { # definir los metadatos de la instancia
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh # definir la clave pública SSH
  }

  # WebServer VNIC
  create_vnic_details { # definir los detalles de la creación de la VNIC
    subnet_id       = oci_core_subnet.WebSubnet.id # definir el OCID de la subred
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.WebSecurityGroup.id, oci_core_network_security_group.SSHSecurityGroup.id] 
  }
}

# WebServer Compute # 2 

resource "oci_core_instance" "Webserver2" { # definir el recurso de la instancia
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name # definir el dominio de disponibilidad de la instancia en caso de que no se haya definido en las variables
  compartment_id      = oci_identity_compartment.Prod_01.id # definir el OCID del compartimento
  display_name        = "WebServer2" # definir el nombre de la instancia
  shape               = var.Shape # definir la forma de la instancia

  dynamic "shape_config" { # definir la configuración de la forma de la instancia
    for_each = local.is_flexible_shape ? [1] : []  # definir si la forma de la instancia es flexible o no lo es 
    content { # definir el contenido de la forma de la instancia
      memory_in_gbs = var.FlexShapeMemory # definir la memoria de la instancia flexible
      ocpus         = var.FlexShapeOCPUS # definir los OCPUs de la instancia flexible
    }
  }

  fault_domain = "FAULT-DOMAIN-2"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }

  metadata = { # definir los metadatos de la instancia
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh # definir la clave pública SSH
  }

  # WebServer VNIC
  create_vnic_details { # definir los detalles de la creación de la VNIC
    subnet_id       = oci_core_subnet.WebSubnet.id # definir el OCID de la subred
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.WebSecurityGroup.id, oci_core_network_security_group.SSHSecurityGroup.id]
  }
}