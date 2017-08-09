<#
    .EXAMPLE
    Remove a Network Team Interface
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
          TeamingMode = 'SwitchIndependent'
          LoadBalancingAlgorithm = 'HyperVPort'
          TeamMembers = 'NIC1','NIC2'
          Ensure = 'Present'
        }
        
        xNetworkTeamInterface NewInterface
        {
            Name = 'NewInterface'
            TeamName = 'HostTeam'
            Ensure = 'Absent'
            DependsOn = '[xNetworkTeam]HostTeam'
        }
    }
}
