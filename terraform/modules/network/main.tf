resource "oci_core_vcn" "palworld_vcn" {
  compartment_id = var.compartment_id

  cidr_block = "10.0.0.0/16"
  display_name = "palworld-vcn"
}

resource "oci_core_internet_gateway" "palworld_ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.palworld_vcn.id
  display_name = "palworld-internet-gateway"
  enabled = true
}

resource "oci_core_route_table" "palworld_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.palworld_vcn.id

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.palworld_ig.id
  }
}

resource "oci_core_security_list" "palworld_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.palworld_vcn.id

  ingress_security_rules {
    protocol    = "17"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    udp_options {
      min = 8211
      max = 8211
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_subnet" "palworld_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.palworld_vcn.id
  cidr_block     = "10.0.0.0/24"
  route_table_id = oci_core_route_table.palworld_rt.id
  security_list_ids = [oci_core_security_list.palworld_sl.id]
}