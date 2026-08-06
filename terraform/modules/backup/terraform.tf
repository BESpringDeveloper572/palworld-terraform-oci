terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
}
