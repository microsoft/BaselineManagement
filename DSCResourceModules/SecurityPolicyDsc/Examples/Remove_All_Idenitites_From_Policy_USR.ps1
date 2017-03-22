Configuration UserRights
{
    Import-DscResource -ModuleName SecurityPolicyDsc

    Node localhost
    {
        UserRightsAssignment RemoveIdsFromSeTrustedCredManAccessPrivilege
        {
            # When Identity is an empty string all identities will be removed from the policy
            Policy = "Access_Credential_Manager_as_a_trusted_caller"
            Identity = ""
        }
    }
}

UserRights -OutputPath c:\dsc

Start-DscConfiguration -Path c:\dsc -Verbose -Wait -Force
