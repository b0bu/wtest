resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "gowtest"
  resource_group_id = data.azurerm_resource_group.rg.id

  amount     = 10
  time_grain = "Monthly"

  time_period {
    start_date = "2025-01-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 50
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_roles = [
      "Owner",
    ]
  }


  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"

    contact_roles = [
      "Owner",
    ]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_roles = [
      "Owner",
    ]

    contact_groups = [
      azurerm_monitor_action_group.deny.id,
    ]
  } // deployments will be frozen

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_roles = [
      "Owner",
    ]
  } // this may or may not be expected
}

