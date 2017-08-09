<#
    .EXAMPLE
    Rename three network adapters identified by MAC addresses to
    Cluster, Management and SMB and then enable DHCP on them.
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
        xNetAdapterName RenameNetAdapterCluster
        {
            NewName        = 'Cluster'
            MacAddress     = '9C-D2-1E-61-B5-DA'
        }

        xDhcpClient EnableDhcpClientCluster
        {
            State          = 'Enabled'
            InterfaceAlias = 'Cluster'
            AddressFamily  = 'IPv4'
        }

        xNetAdapterName RenameNetAdapterManagement
        {
            NewName        = 'Management'
            MacAddress     = '9C-D2-1E-61-B5-DB'
        }

        xDhcpClient EnableDhcpClientManagement
        {
            State          = 'Enabled'
            InterfaceAlias = 'Management'
            AddressFamily  = 'IPv4'
        }

        xNetAdapterName RenameNetAdapterSMB
        {
            NewName        = 'SMB'
            MacAddress     = '9C-D2-1E-61-B5-DC'
        }

        xDhcpClient EnableDhcpClientSMB
        {
            State          = 'Enabled'
            InterfaceAlias = 'SMB'
            AddressFamily  = 'IPv4'
        }
    }
}
