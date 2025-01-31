resource "azurerm_policy_definition" "budget" {
  name         = "gowtest-budget"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "deny resource creation if budget exceeded"

  metadata = <<METADATA
    {
    "category": "Cost Management"
    }
METADATA


  policy_rule = <<POLICY_RULE
{
    "if": {
        "field": "type",
        "equals": "*"
      },
    "then": {
        "effect": "audit"
    }
}
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "budget" {
  name                 = "gowtest"
  policy_definition_id = azurerm_policy_definition.budget.id
  subscription_id      = data.azurerm_subscription.current.id
}

