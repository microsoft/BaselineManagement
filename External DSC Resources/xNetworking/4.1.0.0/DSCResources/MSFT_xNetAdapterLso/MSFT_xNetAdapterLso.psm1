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
    -ResourceName 'MSFT_xNetAdapterLso' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
.SYNOPSIS
    Gets the current state of NetAdapterLso for a adapter.

.PARAMETER Name
    Specifies the name of the network adapter to check.

.PARAMETER Protocol
    Specifies which protocol to target.

.PARAMETER State
    Specifies the LSO state for the protocol.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet("V1IPv4","IPv4","IPv6")]
        [String]
        $Protocol,

        [parameter(Mandatory = $true)]
        [Boolean]
        $State
    )

    try 
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $localizedData.CheckingNetAdapterMessage
        ) -join '')

        $netAdapter = Get-NetAdapterLso -Name $Name -ErrorAction Stop

        if ($netAdapter)
        {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.NetAdapterTestingStateMessage -f $Name, $Protocol)
            ) -join '')

            $result = @{ 
                Name = $Name
                Protocol = $Protocol
            }
            switch ($Protocol) {
                "V1IPv4" { $result.add('State', $netAdapter.V1IPv4Enabled) }
                "IPv4"   { $result.add('State', $netAdapter.IPv4Enabled) }
                "IPv6"   { $result.add('State', $netAdapter.IPv6Enabled) }
                Default {"Should not be called."}
            }
            return $result
        }
    }
    catch 
    {
        throw $localizedData.NetAdapterNotFoundMessage
    }

}

<#
.SYNOPSIS
    Sets the NetAdapterLso resource state.

.PARAMETER Name
    Specifies the name of the network adapter to check.

.PARAMETER Protocol
    Specifies which protocol to target.

.PARAMETER State
    Specifies the LSO state for the protocol.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet("V1IPv4","IPv4","IPv6")]
        [String]
        $Protocol,

        [parameter(Mandatory = $true)]
        [Boolean]
        $State
    )

    try 
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $localizedData.CheckingNetAdapterMessage
        ) -join '')

        $netAdapter = Get-NetAdapterLso -Name $Name -ErrorAction Stop

        if ($netAdapter)
        {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.NetAdapterTestingStateMessage -f $Name, $Protocol)
            ) -join '')

            if ($Protocol -eq "V1IPv4" -and $State -ne $netAdapter.V1IPv4Enabled) 
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.NetAdapterApplyingChangesMessage -f `
                    $Name, $Protocol, $($netAdapter.V1IPv4Enabled.ToString()), $($State.ToString()) )
            )    -join '')
                
                Set-NetAdapterLso -Name $Name -V1IPv4Enabled $State
            }
            elseif ($Protocol -eq "IPv4" -and $State -ne $netAdapter.IPv4Enabled) 
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.NetAdapterApplyingChangesMessage -f `
                    $Name, $Protocol, $($netAdapter.IPv4Enabled.ToString()), $($State.ToString()) )
                ) -join '')

                Set-NetAdapterLso -Name $Name -IPv4Enabled $State
            }
            elseif ($Protocol -eq "IPv6" -and $State -ne $netAdapter.IPv6Enabled) 
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.NetAdapterApplyingChangesMessage -f `
                    $Name, $Protocol, $($netAdapter.IPv6Enabled.ToString()), $($State.ToString()) )
                ) -join '')

                Set-NetAdapterLso -Name $Name -IPv6Enabled $State
            }
        }
    }
    catch 
    {
        throw $LocalizedData.NetAdapterNotFoundMessage
    }

}

<#
.SYNOPSIS
    Tests if the NetAdapterLso resource state is desired state.

.PARAMETER Name
    Specifies the name of the network adapter to check.

.PARAMETER Protocol
    Specifies which protocol to target.

.PARAMETER State
    Specifies the LSO state for the protocol.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet("V1IPv4","IPv4","IPv6")]
        [String]
        $Protocol,

        [parameter(Mandatory = $true)]
        [Boolean]
        $State
    )

    try 
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $localizedData.CheckingNetAdapterMessage
        ) -join '')

        $netAdapter = Get-NetAdapterLso -Name $Name -ErrorAction Stop

        if ($netAdapter) 
        {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $localizedData.NetAdapterTestingStateMessage -f `
                $Name, $Protocol
            ) -join '')

            switch ($Protocol) {
                "V1IPv4" { return ($State -eq $netAdapter.V1IPv4Enabled) }
                "IPv4"   { return ($State -eq $netAdapter.IPv4Enabled) }
                "IPv6"   { return ($State -eq $netAdapter.IPv6Enabled) }
                Default {"Should not be called."}
            }
        }
    }
    catch 
    {
        throw $LocalizedData.NetAdapterNotFoundMessage
    }

}
