resource "oci_identity_policy" "objectstorage_service_policy" {
  compartment_id = var.tenancy_ocid
  name           = "ObjectStorage-Service-Principal-Policy"
  description    = "Allows Object Storage service to manage object-family across the tenancy to process automated actions like PARs."

  statements = [
    "Allow service objectstorage-${var.region} to manage object-family in tenancy"
  ]
}

resource "oci_objectstorage_bucket" "palworld_backups_bucket" {
  compartment_id = var.compartment_id
  name           = "palworld-backups"
  namespace      = data.oci_objectstorage_namespace.my_tenancy_namespace.namespace
}

resource "oci_objectstorage_object" "palworld_backups_to_keep" {
  bucket    = oci_objectstorage_bucket.palworld_backups_bucket.name
  namespace = data.oci_objectstorage_namespace.my_tenancy_namespace.namespace
  object    = "keep/"
  content = ""
}

resource "oci_objectstorage_object_lifecycle_policy" "palworld_backup_delete_old_backups" {
  bucket    = oci_objectstorage_bucket.palworld_backups_bucket.name
  namespace = oci_objectstorage_bucket.palworld_backups_bucket.namespace

  rules {
    action      = "ARCHIVE"
    is_enabled  = true
    name        = "Archive_Old_Backups"
    time_amount = 7
    time_unit   = "DAYS"

    object_name_filter {
      inclusion_patterns = ["palworld-save-*.tar.gz"]
    }
  }

  rules {
    action      = "DELETE"
    is_enabled  = true
    name        = "Permanently_Purge_Really_Old_Backups"
    time_amount = 14
    time_unit   = "DAYS"

    object_name_filter {
      inclusion_patterns = ["palworld-save-*.tar.gz"]
      exclusion_patterns = ["keep/*"]
    }
  }

  depends_on = [
    oci_objectstorage_bucket.palworld_backups_bucket,
    oci_identity_policy.objectstorage_service_policy
  ]
}

resource "oci_identity_dynamic_group" "palworld_server_instance_permission_group" {
  compartment_id = var.tenancy_ocid
  description    = "Palworld instance principal"
  matching_rule  = "Any {instance.id = '${var.instance_id}'}"
  name           = "palworld-server-permissions"
}

resource "oci_identity_policy" "palworld_server_backup_write_permission" {
  compartment_id = var.compartment_id
  description    = "Allow Palworld to write backups to Object Store"
  name           = "palworld-backup-write-permission"
  statements = ["Allow dynamic-group ${oci_identity_dynamic_group.palworld_server_instance_permission_group.name} to manage objects in compartment id ${var.compartment_id} where all {target.bucket.name='${oci_objectstorage_bucket.palworld_backups_bucket.name}', any { request.permission='OBJECT_CREATE', request.permission='OBJECT_READ' }}"]
}