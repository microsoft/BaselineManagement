<#
    .EXAMPLE
    Removing the default gateway from an interface
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
        xDefaultGatewayAddress RemoveDefaultGateway
        {
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
        }
    }
}
