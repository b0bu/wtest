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
  } // trigger deny on resource create

  # notification {
  #   enabled        = true
  #   threshold      = 0
  #   operator       = "EqualTo"
  #   threshold_type = "Actual"

  #   contact_roles = [
  #     "Owner",
  #   ]
  # } // trigger allow on resource create


  notification {
    enabled        = true
    threshold      = 110
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_roles = [
      "Owner",
    ]
  }
}

