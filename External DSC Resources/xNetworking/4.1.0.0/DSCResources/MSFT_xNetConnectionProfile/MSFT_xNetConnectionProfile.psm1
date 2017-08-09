$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Networking Common Modules
Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetworkingDsc.Common' `
                                                     -ChildPath 'NetworkingDsc.Common.psm1'))

# Import the Networking Resource Helper Module
Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetworkingDsc.ResourceHelper' `
                                                     -ChildPath 'NetworkingDsc.ResourceHelper.psm1'))

# Import Localization Strings
$localizedData = Get-LocalizedData `
    -ResourceName 'MSFT_xNetConnectionProfile' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current Networking Connection Profile for the specified interface.

    .PARAMETER InterfaceAlias
    Specifies the alias for the Interface that is being changed.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [string]
        $InterfaceAlias
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingNetConnectionProfile) -f $InterfaceAlias
    ) -join '')

    $result = Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias

    return @{
        InterfaceAlias   = $result.InterfaceAlias
        NetworkCategory  = $result.NetworkCategory
        IPv4Connectivity = $result.IPv4Connectivity
        IPv6Connectivity = $result.IPv6Connectivity
    }
}

<#
    .SYNOPSIS
    Sets the Network Connection Profile for a specified interface.

    .PARAMETER InterfaceAlias
    Specifies the alias for the Interface that is being changed.

    .PARAMETER IPv4Connectivity
    Specifies the network interfaces that should be a part of the network team.
    This is a comma-separated list.

    .PARAMETER IPv6Connectivity
    Specifies the teaming mode configuration.

    .PARAMETER NetworkCategory
    Specifies the load balancing algorithm for the network team.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $InterfaceAlias,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string]
        $IPv4Connectivity,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string]
        $IPv6Connectivity,

        [ValidateSet('Public', 'Private')]
        [string]
        $NetworkCategory
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.SetNetConnectionProfile) -f $InterfaceAlias
    ) -join '')

    Set-NetConnectionProfile @PSBoundParameters
}

<#
    .SYNOPSIS
    Tests is the Network Connection Profile for the specified interface is in the correct state.

    .PARAMETER InterfaceAlias
    Specifies the alias for the Interface that is being changed.

    .PARAMETER IPv4Connectivity
    Specifies the network interfaces that should be a part of the network team.
    This is a comma-separated list.

    .PARAMETER IPv6Connectivity
    Specifies the teaming mode configuration.

    .PARAMETER NetworkCategory
    Specifies the load balancing algorithm for the network team.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $InterfaceAlias,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string]
        $IPv4Connectivity,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string]
        $IPv6Connectivity,

        [ValidateSet('Public', 'Private')]
        [string]
        $NetworkCategory
    )

    $current = Get-TargetResource -InterfaceAlias $InterfaceAlias

    if ($IPv4Connectivity -ne $current.IPv4Connectivity)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestIPv4Connectivity) -f $IPv4Connectivity, $current.IPv4Connectivity
        ) -join '')

        return $false
    }

    if ($IPv6Connectivity -ne $current.IPv6Connectivity)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestIPv6Connectivity) -f $IPv6Connectivity, $current.IPv6Connectivity
        ) -join '')

        return $false
    }

    if ($NetworkCategory -ne $current.NetworkCategory)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestNetworkCategory) -f $NetworkCategory, $current.NetworkCategory
        ) -join '')

        return $false
    }

    return $true
}
