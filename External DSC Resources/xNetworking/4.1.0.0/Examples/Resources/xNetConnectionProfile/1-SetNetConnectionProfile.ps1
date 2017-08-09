<#
    .EXAMPLE
    Sets the Ethernet adapter to Public and IPv4/6 to Internet Connectivity
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -Module xNetworking

    Node $NodeName
    {
        xNetConnectionProfile Example
        {
            InterfaceAlias   = 'Ethernet'
            NetworkCategory  = 'Public'
            IPv4Connectivity = 'Internet'
            IPv6Connectivity = 'Internet'
        }
    }
}
