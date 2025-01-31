terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
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

provider "external" {}
provider "time" {}
provider "http" {}