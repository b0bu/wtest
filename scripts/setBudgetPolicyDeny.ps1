$policy = Get-AzPolicyDefinition -Name "gowtest"
$policy.Properties.policyRule = @{
    "if" = @{
        "field" = "type"
        "equals" = "*"
    }
    "then" = @{
        "effect" = "deny"
    }
}
Set-AzPolicyDefinition -Id $policy.PolicyDefinitionId -Policy $policy.Properties.policyRule