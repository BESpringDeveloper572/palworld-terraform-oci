data "oci_objectstorage_namespace" "my_tenancy_namespace" {}

data "oci_identity_compartment" "my_compartment" {
  id = var.compartment_id
}