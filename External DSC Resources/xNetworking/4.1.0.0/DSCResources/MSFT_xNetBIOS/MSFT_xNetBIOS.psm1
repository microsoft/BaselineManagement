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
    -ResourceName 'MSFT_xNetBIOS' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

#region check NetBIOSSetting enum loaded, if not load
try
{
    [void][reflection.assembly]::GetAssembly([NetBIOSSetting])
}
catch
{
    Add-Type -TypeDefinition @'
    public enum NetBiosSetting
    {
       Default,
       Enable,
       Disable
    }
'@
}
#endregion

<#
    .SYNOPSIS
    Returns the current state of the Net Bios on an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER Setting
    Default - Use NetBios settings from the DHCP server. If static IP, Enable NetBIOS.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InterfaceAlias,

        [parameter(Mandatory = $true)]
        [ValidateSet("Default","Enable","Disable")]
        [System.String]
        $Setting
    )

    Write-Verbose -Message ($LocalizedData.GettingNetBiosSetting -f $InterfaceAlias)

    $netadapterparams = @{
        ClassName = 'Win32_NetworkAdapter'
        Filter = 'NetConnectionID="{0}"' -f $InterfaceAlias
    }

    $netAdapterConfig = Get-CimInstance @netadapterparams -ErrorAction Stop |
            Get-CimAssociatedInstance `
                -ResultClassName Win32_NetworkAdapterConfiguration `
                -ErrorAction Stop

    return @{
        InterfaceAlias = $InterfaceAlias
        Setting = $([NETBIOSSetting].GetEnumValues()[$netAdapterConfig.TcpipNetbiosOptions])
    }
}

<#
    .SYNOPSIS
    Sets the state of the Net Bios on an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER Setting
    Default - Use NetBios settings from the DHCP server. If static IP, Enable NetBIOS.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InterfaceAlias,

        [parameter(Mandatory = $true)]
        [ValidateSet("Default","Enable","Disable")]
        [System.String]
        $Setting
    )

    $netadapterparams = @{
        ClassName = 'Win32_NetworkAdapter'
        Filter = 'NetConnectionID="{0}"' -f $InterfaceAlias
    }
    $netAdapterConfig = Get-CimInstance @netadapterparams -ErrorAction Stop |
            Get-CimAssociatedInstance `
                -ResultClassName Win32_NetworkAdapterConfiguration `
                -ErrorAction Stop

    if ($Setting -eq [NETBIOSSetting]::Default)
    {
        Write-Verbose -Message $LocalizedData.ResetToDefaut
        #If DHCP is not enabled, settcpipnetbios CIM Method won't take 0 so overwrite registry entry instead.
        $regParam = @{
            Path = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$($NetAdapterConfig.SettingID)"
            Name = 'NetbiosOptions'
            Value = 0
        }
        $null = Set-ItemProperty @regParam
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.SetNetBIOS -f $Setting)
        $null = $netAdapterConfig |
            Invoke-CimMethod -MethodName SetTcpipNetbios -ErrorAction Stop -Arguments @{
                TcpipNetbiosOptions = [uint32][NETBIOSSetting]::$Setting.value__
            }
    }
}

<#
    .SYNOPSIS
    Tests the current state the Net Bios on an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface. Supports the use of '*'.

    .PARAMETER Setting
    Default - Use NetBios settings from the DHCP server. If static IP, Enable NetBIOS.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InterfaceAlias,

        [parameter(Mandatory = $true)]
        [ValidateSet("Default","Enable","Disable")]
        [System.String]
        $Setting
    )

    $nic = Get-CimInstance `
        -ClassName Win32_NetworkAdapter `
        -Filter "NetConnectionID=`"$InterfaceAlias`""
    if ($null -ne $nic)
    {
        Write-Verbose -Message ($LocalizedData.InterfaceDetected -f $InterfaceAlias,$nic.InterfaceIndex)
    }
    else
    {
        $errorParam = @{
            Message = ($LocalizedData.NICNotFound -f $InterfaceAlias)
            ArgumentName = 'InterfaceAlias'
        }
        New-InvalidArgumentException @errorParam
    }

    $nicConfig = $NIC | Get-CimAssociatedInstance -ResultClassName Win32_NetworkAdapterConfiguration

    Write-Verbose -Message ($LocalizedData.CurrentNetBiosSetting -f [NETBIOSSetting].GetEnumValues()[$NICConfig.TcpipNetbiosOptions])

    $desiredSetting = ([NETBIOSSetting]::$($Setting)).value__
    Write-Verbose -Message ($LocalizedData.DesiredSetting -f $Setting)

    if ($nicConfig.TcpipNetbiosOptions -eq $desiredSetting)
    {
        Write-Verbose -Message $LocalizedData.InDesiredState
        return $true
    }
    else
    {
        Write-Verbose -Message $LocalizedData.NotInDesiredState
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource
