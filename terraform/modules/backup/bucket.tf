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

resource "time_offset" "palworld_par_url_expire_time" {
  offset_years = 5
}

resource "oci_objectstorage_preauthrequest" "palworld_par_upload_url" {
  bucket       = oci_objectstorage_bucket.palworld_backups_bucket.name
  namespace    = oci_objectstorage_bucket.palworld_backups_bucket.namespace
  access_type  = "AnyObjectWrite"
  name         = "palworld_par_upload"
  time_expires = time_offset.palworld_par_url_expire_time.rfc3339
  depends_on = [oci_objectstorage_bucket.palworld_backups_bucket]
}
