variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "oci_private_key_path" {
  type = string
}

variable "oci_private_key_password" {
  type = string
}

variable "oci_comparment_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "instance_timezone" {
  default = "UTC"
}

variable "region" {
  type = string
}