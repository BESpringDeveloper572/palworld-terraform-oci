module "network" {
  source                   = "./modules/network"
  compartment_id = var.oci_comparment_id
}

module "server" {
  source                   = "./modules/server"
  compartment_id = var.oci_comparment_id
  subnet_id = module.network.subnet_id
  tenancy_ocid = var.tenancy_ocid
  image_id = var.image_id
  ssh_public_key_path = var.ssh_public_key_path
  instance_timezone = var.instance_timezone
  ssh_private_key_path = var.ssh_private_key_path
}

module "backup" {
  source                   = "./modules/backup"
  compartment_id = var.oci_comparment_id
  tenancy_ocid = var.tenancy_ocid
  region = var.region
  instance_id = module.server.instance-OCID
}