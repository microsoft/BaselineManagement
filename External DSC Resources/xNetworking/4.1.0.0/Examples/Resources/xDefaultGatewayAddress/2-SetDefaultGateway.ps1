<#
    .EXAMPLE
    Adding a default gateway to the interface
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
        xDefaultGatewayAddress SetDefaultGateway
        {
            Address        = '192.168.1.1'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv6'
        }
    }
}
