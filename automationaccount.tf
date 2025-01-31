resource "azurerm_role_assignment" "policy" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Resource Policy Contributor"
  principal_id         = azurerm_automation_account.aa.identity[0].principal_id
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
  name                    = local.deny
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
  name                    = local.allow
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

resource "time_rotating" "expiry" {
  rotation_days = 30
}

resource "azurerm_automation_webhook" "allowhook" {
  name                    = local.allow
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  expiry_time             = time_rotating.expiry.id
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.allow.name
  parameters = {
    input = "parameter"
  }
}

resource "azurerm_monitor_action_group" "allow" {
  name                = local.allow
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = "allow"

  automation_runbook_receiver {
    name                    = azurerm_automation_account.aa.name
    automation_account_id   = azurerm_automation_account.aa.id
    runbook_name            = local.allow
    webhook_resource_id     = azurerm_automation_webhook.allowhook.id
    is_global_runbook       = true
    service_uri             = azurerm_automation_webhook.allowhook.uri
    use_common_alert_schema = true
  }
}