resource "azurerm_service_plan" "gowtest" {
  name                = "gowtest"
  location            = "uksouth"
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "F1"
}