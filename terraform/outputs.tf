output "public-ip-for-compute-instance" {
  value = module.server.public-ip-for-compute-instance
}

output "instance-name" {
  value = module.server.instance-name
}

output "instance-OCID" {
  value = module.server.instance-OCID
}

output "instance-state" {
  value = module.server.instance-state
}
