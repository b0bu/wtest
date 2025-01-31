$policy = Get-AzPolicyDefinition -Name "gowtest"
$policy.Properties.policyRule = @{
    "if" = @{
        "field" = "type"
        "equals" = "*"
    }
    "then" = @{
        "effect" = "audit"
    }
}
Set-AzPolicyDefinition -Id $policy.PolicyDefinitionId -Policy $policy.Properties.policyRule