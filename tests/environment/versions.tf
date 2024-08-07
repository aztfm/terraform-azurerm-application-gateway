terraform {
  required_version = ">=1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "0.2.5"
    }
  }
}
