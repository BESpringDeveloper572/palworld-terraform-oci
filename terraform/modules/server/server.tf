resource "oci_core_instance" "palworld_server" {
    display_name = "palworld-server"
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = var.compartment_id
    shape = "VM.Standard.A1.Flex"
    shape_config {
        ocpus = "2"
        memory_in_gbs = "12"
    }
    source_details {
        source_id = var.image_id
        source_type = "image"
    }

    create_vnic_details {
        assign_public_ip = true
        subnet_id = var.subnet_id
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_public_key_path)
        user_data = base64encode(<<-EOF
          #cloud-config
          timezone: ${var.instance_timezone}
        EOF
        )
    }
    preserve_boot_volume = false
}
