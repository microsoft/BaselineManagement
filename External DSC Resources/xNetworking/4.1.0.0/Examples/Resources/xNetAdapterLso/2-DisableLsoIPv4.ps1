<#
    .EXAMPLE
    This configuration disables LSO for IPv4 on the network adapter.
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
        xNetAdapterLso DisableLsoIPv4
        {
            Name = 'Ethernet'
            Protocol = 'IPv4'
            State = $false
        }
    }
}
