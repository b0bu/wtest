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

  site_config {
    always_on = false
    application_stack {
      docker_image_name        = "gowtest:0.0.1"
      docker_registry_url      = "registry.hub.docker.com"
      docker_registry_username = "maclighiche"
      docker_registry_password = var.docker_registry_password
    }
  }
}