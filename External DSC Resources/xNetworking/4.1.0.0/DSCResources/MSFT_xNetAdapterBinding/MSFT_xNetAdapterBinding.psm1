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
    -ResourceName 'MSFT_xNetAdapterBinding' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current state of an Adapter Binding on an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER ComponentId
    Specifies the underlying name of the transport or filter in the following
    form - ms_xxxx, such as ms_tcpip.

    .PARAMETER Ensure
    Specifies if the component ID for the Interface should be Enabled or Disabled.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State = 'Enabled'
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingNetAdapterBindingMessage -f `
            $InterfaceAlias,$ComponentId)
        ) -join '')

    $currentNetAdapterBinding = Get-Binding @PSBoundParameters

    $adapterState = $currentNetAdapterBinding.Enabled |
        Sort-Object -Unique

    if ( $adapterState.Count -eq 2)
    {
        $currentEnabled = 'Mixed'
    }
    elseif ( $adapterState -eq $true )
    {
        $currentEnabled = 'Enabled'
    }
    else
    {
        $currentEnabled = 'Disabled'
    }

    $returnValue = @{
        InterfaceAlias = $InterfaceAlias
        ComponentId    = $ComponentId
        State          = $State
        CurrentState   = $currentEnabled
    }

    return $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    Sets the Adapter Binding on a specific interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER ComponentId
    Specifies the underlying name of the transport or filter in the following
    form - ms_xxxx, such as ms_tcpip.

    .PARAMETER Ensure
    Specifies if the component ID for the Interface should be Enabled or Disabled.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State = 'Enabled'
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingNetAdapterBindingMessage -f `
            $InterfaceAlias,$ComponentId)
        ) -join '')

    $currentNetAdapterBinding = Get-Binding @PSBoundParameters

    # Remove the State so we can splat
    $null = $PSBoundParameters.Remove('State')

    if ($State -eq 'Enabled')
    {
        Enable-NetAdapterBinding @PSBoundParameters
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingEnabledMessage -f `
                $InterfaceAlias,$ComponentId)
            ) -join '' )
    }
    else
    {
        Disable-NetAdapterBinding @PSBoundParameters
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingDisabledMessage -f `
                $InterfaceAlias,$ComponentId)
            ) -join '' )
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests the current state of an Adapter Binding on an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER ComponentId
    Specifies the underlying name of the transport or filter in the following
    form - ms_xxxx, such as ms_tcpip.

    .PARAMETER Ensure
    Specifies if the component ID for the Interface should be Enabled or Disabled.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State = 'Enabled'
    )

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingNetAdapterBindingMessage -f `
            $InterfaceAlias,$ComponentId)
        ) -join '')

    $currentNetAdapterBinding = Get-Binding @PSBoundParameters

    $adapterState = $currentNetAdapterBinding.Enabled |
        Sort-Object -Unique

    if ( $adapterState.Count -eq 2)
    {
        $currentEnabled = 'Mixed'
    }
    elseif ( $adapterState -eq $true )
    {
        $currentEnabled = 'Enabled'
    }
    else
    {
        $currentEnabled = 'Disabled'
    }

    # Test if the binding is in the correct state
    if ($currentEnabled -ne $State)
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingDoesNotMatchMessage -f `
                $InterfaceAlias,$ComponentId,$State,$currentEnabled)
            ) -join '' )
        return $false
    }
    else
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterBindingMatchMessage -f `
                $InterfaceAlias,$ComponentId)
            ) -join '' )
        return $true
    } # if
} # Test-TargetResource

<#
    .SYNOPSIS
    Ensures the interface and component Id exists and returns the Net Adapter binding object.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER ComponentId
    Specifies the underlying name of the transport or filter in the following
    form - ms_xxxx, such as ms_tcpip.

    .PARAMETER Ensure
    Specifies if the component ID for the Interface should be Enabled or Disabled.
#>
function Get-Binding
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComponentId,

        [ValidateSet('Enabled', 'Disabled')]
        [String]
        $State = 'Enabled'
    )

    if (-not (Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue))
    {
        $errorId = 'InterfaceNotAvailable'
        $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
        $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $InterfaceAlias
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    } # if

    $binding = Get-NetAdapterBinding `
        -InterfaceAlias $InterfaceAlias `
        -ComponentId $ComponentId `
        -ErrorAction Stop

    return $binding
} # Get-Binding

Export-ModuleMember -function *-TargetResource
