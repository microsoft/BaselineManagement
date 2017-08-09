<#
    .EXAMPLE
    Configure primary and secondary DNS Server addresses on the Ethernet adapter
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
        xDnsServerAddress DnsServerAddress
        {
            Address        = '10.0.0.2','10.0.0.40'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            Validate       = $true
        }
    }
}
