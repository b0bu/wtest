data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_automation_account" "aa" {
  name                = "gowtest-budget"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_automation_runbook" "deny" {
  name                    = "Set-BudgetPolicyAllow"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "deny creation of resources"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/b0bu/wtest/refs/heads/main/scripts/setBudgetPolicyDeny.ps1"
  }
}

resource "azurerm_automation_runbook" "allow" {
  name                    = "Set-BudgetPolicyAllow"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "allow creation of resources"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/b0bu/wtest/refs/heads/main/scripts/setBudgetPolicyAllow.ps1"
  }
}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Resource Policy Contributor"
  principal_id         = azurerm_automation_account.aa.identity[0].principal_id
}

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

// deployed in audit mode until action_group fires to set enforcing
/*
creation automation account with managed identity
create powershell script set audit and set deny based on action trigger
create action trigger to update when 
*/
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
