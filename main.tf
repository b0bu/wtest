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
  }
}