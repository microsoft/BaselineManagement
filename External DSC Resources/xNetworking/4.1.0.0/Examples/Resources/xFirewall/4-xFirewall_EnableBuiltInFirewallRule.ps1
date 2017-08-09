<#
    .EXAMPLE
    DSC configuration that enables the built-in Firewall Rule
    'World Wide Web Services (HTTP Traffic-In)'
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
            Name                  = 'IIS-WebServerRole-HTTP-In-TCP'
            Ensure                = 'Present'
            Enabled               = 'True'
        }
    }
}
