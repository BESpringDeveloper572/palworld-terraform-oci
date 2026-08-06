output "palworld_backup_upload_url" {
  value = oci_objectstorage_preauthrequest.palworld_par_upload_url.access_uri
}