terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
  }
}
