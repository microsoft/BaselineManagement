<#
    .EXAMPLE
    Disable NetBios on Adapter
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName xNetworking

    node $NodeName 
    {
        xNetBIOS DisableNetBIOS 
        {
            InterfaceAlias = 'Ethernet'
            Setting        = 'Disable'
        }
    }
}
