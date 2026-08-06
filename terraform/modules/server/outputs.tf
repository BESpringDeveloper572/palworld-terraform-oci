output "public-ip-for-compute-instance" {
  value = oci_core_instance.palworld_server.public_ip
}

output "instance-name" {
  value = oci_core_instance.palworld_server.display_name
}

output "instance-OCID" {
  value = oci_core_instance.palworld_server.id
}

output "instance-region" {
  value = oci_core_instance.palworld_server.region
}

output "instance-shape" {
  value = oci_core_instance.palworld_server.shape
}

output "instance-state" {
  value = oci_core_instance.palworld_server.state
}

output "instance-OCPUs" {
  value = oci_core_instance.palworld_server.shape_config[0].ocpus
}

output "instance-memory-in-GBs" {
  value = oci_core_instance.palworld_server.shape_config[0].memory_in_gbs
}

output "time-created" {
  value = oci_core_instance.palworld_server.time_created
}