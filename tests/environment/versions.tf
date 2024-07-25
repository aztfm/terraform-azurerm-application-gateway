terraform {
  required_version = ">=1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}
