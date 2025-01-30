data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "budget" {
  name            = "gowtest"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 10
  time_grain = "Monthly"

  time_period {
    start_date = "2025-01-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_roles = [
      "Owner",
    ]
  }
}

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
        "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Consumption/budgets"
        },
        {
          "field": "name",
          "equals": "${var.resource_group_name}"
        },
        {
          "field": "type",
          "greaterOrEquals": "10"
        }
      ]
    },
    "then": {
        "effect": "deny"
    }
}
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "budget" {
  name                 = "gowtest"
  policy_definition_id = azurerm_policy_definition.budget.id
  subscription_id      = data.azurerm_subscription.current.id
}