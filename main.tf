data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "http" "docker_io" {
  url = "https://hub.docker.com/v2/namespaces/${var.docker_registry_username}/repositories/gowtest/tags?page_size=100"
}

resource "terraform_data" "image_tag" {
  input = jsondecode(data.http.docker_io.response_body).results[0].name
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

  app_settings = {
    WEBSITES_PORT = "8080"
  }

  site_config {
    always_on = false
    application_stack {
      docker_image_name   = "${var.docker_registry_username}/gowtest:${terraform_data.image_tag.output}"
      docker_registry_url = "https://index.docker.io"
    }
  }
}