terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }

    azapi = {
      source  = "hashicorp/azapi"
      version = "1.15.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "ba85ac8f-51e0-413f-80a5-d6ab685dbd51"
  features {}
}