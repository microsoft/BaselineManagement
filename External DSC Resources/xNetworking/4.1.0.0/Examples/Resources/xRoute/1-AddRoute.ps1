<#
    .EXAMPLE
    Add a net route to the Ethernet interface
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
        xRoute NetRoute1
        {
            Ensure = 'Present'
            InterfaceAlias = 'Ethernet'
            AddressFamily = 'IPv4'
            DestinationPrefix = '192.168.0.0/16'
            NextHop = '192.168.120.0'
            RouteMetric = 200
        }
    }
}
