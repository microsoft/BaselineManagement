<#
    .EXAMPLE
    Rename the first three network adapters with Driver Description matching
    'Hyper-V Virtual Ethernet Adapter' in consequtive order to Cluster, Management
    and SMB and then enable DHCP on them.
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
            NewName           = 'Cluster'
            DriverDescription = 'Hyper-V Virtual Ethernet Adapter'
            InterfaceNumber   = 1
        }

        xDhcpClient EnableDhcpClientCluster
        {
            State          = 'Enabled'
            InterfaceAlias = 'Cluster'
            AddressFamily  = 'IPv4'
        }

        xNetAdapterName RenameNetAdapterManagement
        {
            NewName           = 'Management'
            DriverDescription = 'Hyper-V Virtual Ethernet Adapter'
            InterfaceNumber   = 2
        }

        xDhcpClient EnableDhcpClientManagement
        {
            State          = 'Enabled'
            InterfaceAlias = 'Management'
            AddressFamily  = 'IPv4'
        }

        xNetAdapterName RenameNetAdapterSMB
        {
            NewName           = 'SMB'
            DriverDescription = 'Hyper-V Virtual Ethernet Adapter'
            InterfaceNumber   = 3
        }

        xDhcpClient EnableDhcpClientSMB
        {
            State          = 'Enabled'
            InterfaceAlias = 'SMB'
            AddressFamily  = 'IPv4'
        }
    }
}
