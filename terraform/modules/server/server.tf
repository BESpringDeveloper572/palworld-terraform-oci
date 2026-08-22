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
    }
    preserve_boot_volume = false
}

resource "local_file" "ansible_hosts" {
    filename = "${path.root}/../ansible/hosts.ini"
    content = templatefile("${path.root}/../ansible/hosts.ini.tpl", {
        web_ips = [oci_core_instance.palworld_server.private_ip]
        ssh_private_key_path = var.ssh_private_key_path
    })
}
