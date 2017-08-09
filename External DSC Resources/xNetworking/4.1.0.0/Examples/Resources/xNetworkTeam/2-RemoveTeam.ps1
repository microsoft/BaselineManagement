<#
    .EXAMPLE
    Removes the NIC Team for the listed interfacess.
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
        xNetworkTeam HostTeam
        {
            Name = 'HostTeam'
            Ensure = 'Absent'
            TeamMembers = 'NIC1','NIC2','NIC3'
        }
    }
}
