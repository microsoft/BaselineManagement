
$rule = @{

    Policy   = 'Access_Credential_Manager_as_a_trusted_caller'
    Identity = 'builtin\Administrators'
}

$removeAll = @{
    
    Policy = 'Act_as_part_of_the_operating_system'
    Identity = ""
}

configuration MSFT_UserRightsAssignment_config {
    Import-DscResource -ModuleName SecurityPolicyDsc
    
    UserRightsAssignment AccessCredentialManagerAsaTrustedCaller
    {
        # Assign shutdown privileges to only Builtin\Administrators
        Policy   = $rule.Policy
        Identity = $rule.Identity
    }
    
    UserRightsAssignment RemoveAllActAsOS
    {
        Policy   = $removeAll.Policy
        Identity = $removeAll.Identity
    }
    
}
