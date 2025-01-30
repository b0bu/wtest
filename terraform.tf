terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = "gowtest"
    key                  = "terraform.tfstate"

  }
}

provider "azurerm" {
  features {}
  resource_providers_to_register = ["Microsoft.ServiceLinker"]
  tenant_id                      = var.tenant_id
  subscription_id                = var.subscription_id
}