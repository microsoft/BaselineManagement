Configuration UserRights
{
    Import-DscResource -ModuleName SecurityPolicyDsc

    Node localhost
    {
        #Assign shutdown privileges to only Builtin\Administrators
        UserRightsAssignment AssignShutdownPrivlegesToAdmins
        {            
            Policy = "Shut_down_the_system"
            Identity = "Builtin\Administrators"
        }

        #Assign access from the network privileges to "contoso\TestUser1" and "whlab\TestUser2"
        UserRightsAssignment AccessComputerFromNetwork
        {
            Policy = "Access_this_computer_from_the_network"
            Identity = "contoso\TestUser1","contoso\TestUser2"
        }
    }
}

UserRights -OutputPath c:\dsc

Start-DscConfiguration -Path c:\dsc -Verbose -Wait -Force
