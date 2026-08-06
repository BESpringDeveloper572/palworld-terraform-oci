terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.25.0"
    }
  }

  required_version = ">= 1.2"
}
