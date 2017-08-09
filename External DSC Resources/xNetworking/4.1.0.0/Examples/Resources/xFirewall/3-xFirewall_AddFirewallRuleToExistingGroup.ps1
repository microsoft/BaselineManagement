<#
    .EXAMPLE
    Adding a firewall to an existing Firewall group 'My Firewall Rule'
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = 'MyFirewallRule'
            DisplayName           = 'My Firewall Rule'
            Group                 = 'My Firewall Rule Group'
        }

        xFirewall Firewall1
        {
            Name                  = 'MyFirewallRule1'
            DisplayName           = 'My Firewall Rule'
            Group                 = 'My Firewall Rule Group'
            Ensure                = 'Present'
            Enabled               = 'True'
            Profile               = ('Domain', 'Private')
        }
    }
}
