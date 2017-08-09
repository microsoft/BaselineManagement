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
    -ResourceName 'MSFT_xDhcpClient' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current state of the DHCP Client for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DHCP Client is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER State
    The desired state of the DHCP Client.
#>
function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingDHCPClientMessage) `
        -f $InterfaceAlias,$AddressFamily `
        ) -join '')

    Assert-ResourceProperty @PSBoundParameters

    $CurrentDHCPClient = Get-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily

    $returnValue = @{
        State          = $CurrentDHCPClient.Dhcp
        AddressFamily  = $AddressFamily
        InterfaceAlias = $InterfaceAlias
    }

    $returnValue
}

<#
    .SYNOPSIS
    Sets the DHCP Client for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DHCP Client is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER State
    The desired state of the DHCP Client.
#>
function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingDHCPClientMessage) `
        -f $InterfaceAlias,$AddressFamily `
        ) -join '')

    Assert-ResourceProperty @PSBoundParameters

    $CurrentDHCPClient = Get-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily

    # The DHCP Client is in a different state - so change it.
    Set-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily `
        -Dhcp $State `
        -ErrorAction Stop

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.DHCPClientSetStateMessage) `
        -f $InterfaceAlias,$AddressFamily,$State `
        ) -join '' )

} # Set-TargetResource

<#
    .SYNOPSIS
    Tests the state of the DHCP Client for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DHCP Client is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER State
    The desired state of the DHCP Client.
#>
function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State
    )

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingDHCPClientMessage) `
        -f $InterfaceAlias,$AddressFamily `
        ) -join '')

    Assert-ResourceProperty @PSBoundParameters

    $CurrentDHCPClient = Get-NetIPInterface `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily

    # The DHCP Client is in a different state - so change it.
    if ($CurrentDHCPClient.DHCP -ne $State)
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.DHCPClientDoesNotMatchMessage) `
            -f $InterfaceAlias,$AddressFamily,$State `
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
    Function will check the interface exists.
    If any problems are detected an exception will be thrown.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DHCP Client is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER State
    The desired state of the DHCP Client.
#>
function Assert-ResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State
    )

    if (-not (Get-NetAdapter | Where-Object -Property Name -EQ $InterfaceAlias ))
    {
        $errorId = 'InterfaceNotAvailable'
        $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
        $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $InterfaceAlias
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
} # Assert-ResourceProperty

Export-ModuleMember -function *-TargetResource
