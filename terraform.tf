terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = var.sa_resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"

  }
}

// 
provider "azurerm" {
  features {}
  tenant_id       = "96229c6d-473d-4d98-a982-6b2293f9b1e5"
  subscription_id = var.subscription_id
}