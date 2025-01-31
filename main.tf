data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "external" "version" {
  program = ["bash", "${path.module}/scripts/version.sh"]
}

resource "azurerm_service_plan" "gowtest" {
  name                = "gowtest"
  location            = "uksouth"
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "gowtest" {
  name                = "gowtest"
  resource_group_name = var.resource_group_name
  location            = "uksouth"
  service_plan_id     = azurerm_service_plan.gowtest.id

  #   app_settings = {
  #     WEBSITES_PORT = "8080"
  #   }

  site_config {
    always_on = false
    application_stack {
      docker_image_name        = "gowtest:${data.external.version.result["sha"]}"
      docker_registry_url      = "https://index.docker.io"
      docker_registry_username = var.docker_registry_username
      docker_registry_password = var.docker_registry_password
    }
  }
}