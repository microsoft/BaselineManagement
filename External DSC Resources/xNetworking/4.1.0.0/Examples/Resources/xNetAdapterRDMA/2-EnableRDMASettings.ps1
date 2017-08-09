<#
    .EXAMPLE
    This configuration enables RDMA setting on the network adapter.
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
        xNetAdapterRDMA SMBAdapter1
        {
            Name = 'SMB1_1'
            Enabled = $true
        }
    }
}
