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
    -ResourceName 'MSFT_xNetAdapterName' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    This function will get the network adapter based on the provided
    parameters.

    .PARAMETER NewName
    Specifies the new name of the network adapter.

    .PARAMETER Name
    This is the name of the network adapter to find.

    .PARAMETER PhysicalMediaType
    This is the media type of the network adapter to find.

    .PARAMETER Status
    This is the status of the network adapter to find.

    .PARAMETER MacAddress
    This is the MAC address of the network adapter to find.

    .PARAMETER InterfaceDescription
    This is the interface description of the network adapter to find.

    .PARAMETER InterfaceIndex
    This is the interface index of the network adapter to find.

    .PARAMETER InterfaceGuid
    This is the interface GUID of the network adapter to find.

    .PARAMETER DriverDescription
    This is the driver description of the network adapter.

    .PARAMETER InterfaceNumber
    This is the interface number of the network adapter if more than one
    are returned by the parameters.

    .PARAMETER IgnoreMultipleMatchingAdapters
    This switch will suppress an error occurring if more than one matching
    adapter matches the parameters passed.
#>
function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewName,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $PhysicalMediaType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [System.String]
        $Status = 'Up',

        [Parameter()]
        [System.String]
        $MacAddress,

        [Parameter()]
        [System.String]
        $InterfaceDescription,

        [Parameter()]
        [System.UInt32]
        $InterfaceIndex,

        [Parameter()]
        [System.String]
        $InterfaceGuid,

        [Parameter()]
        [System.String]
        $DriverDescription,

        [Parameter()]
        [System.UInt32]
        $InterfaceNumber = 1,

        [Parameter()]
        [System.Boolean]
        $IgnoreMultipleMatchingAdapters = $false
    )

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingNetAdapterNameMessage)
        ) -join '')

    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('NewName')

    $adapter = Find-NetworkAdapter `
        @PSBoundParameters `
        -ErrorAction Stop

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.NetAdapterNameFoundMessage -f $adapter.Name)
        ) -join '')

    $returnValue = @{
        Name                           = $adapter.Name
        PhysicalMediaType              = $adapter.PhysicalMediaType
        Status                         = $adapter.Status
        MacAddress                     = $adapter.MacAddress
        InterfaceDescription           = $adapter.InterfaceDescription
        InterfaceIndex                 = $adapter.InterfaceIndex
        InterfaceGuid                  = $adapter.InterfaceGuid
        DriverDescription              = $adapter.DriverDescription
        InterfaceNumber                = $InterfaceNumber
        IgnoreMultipleMatchingAdapters = $IgnoreMultipleMatchingAdapters
    }

    return $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    This function will rename a network adapter that matches the parameters.

    .PARAMETER NewName
    Specifies the new name of the network adapter.

    .PARAMETER Name
    This is the name of the network adapter to find.

    .PARAMETER PhysicalMediaType
    This is the media type of the network adapter to find.

    .PARAMETER Status
    This is the status of the network adapter to find.

    .PARAMETER MacAddress
    This is the MAC address of the network adapter to find.

    .PARAMETER InterfaceDescription
    This is the interface description of the network adapter to find.

    .PARAMETER InterfaceIndex
    This is the interface index of the network adapter to find.

    .PARAMETER InterfaceGuid
    This is the interface GUID of the network adapter to find.

    .PARAMETER DriverDescription
    This is the driver description of the network adapter.

    .PARAMETER InterfaceNumber
    This is the interface number of the network adapter if more than one
    are returned by the parameters.

    .PARAMETER IgnoreMultipleMatchingAdapters
    This switch will suppress an error occurring if more than one matching
    adapter matches the parameters passed.
#>
function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewName,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $PhysicalMediaType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [System.String]
        $Status = 'Up',

        [Parameter()]
        [System.String]
        $MacAddress,

        [Parameter()]
        [System.String]
        $InterfaceDescription,

        [Parameter()]
        [System.UInt32]
        $InterfaceIndex,

        [Parameter()]
        [System.String]
        $InterfaceGuid,

        [Parameter()]
        [System.String]
        $DriverDescription,

        [Parameter()]
        [System.UInt32]
        $InterfaceNumber = 1,

        [Parameter()]
        [System.Boolean]
        $IgnoreMultipleMatchingAdapters = $false
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingNetAdapterNameMessage)
        ) -join '')

    $null = $PSBoundParameters.Remove('NewName')

    $adapter = Find-NetworkAdapter `
        @PSBoundParameters `
        -ErrorAction Stop

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.RenamingNetAdapterNameMessage -f $adapter.Name,$NewName)
        ) -join '')

    $adapter | Rename-NetAdapter -NewName $NewName

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.NetAdapterNameRenamedMessage -f $NewName)
        ) -join '')
} # Set-TargetResource

<#
    .SYNOPSIS
    This will check if the network adapter that matches the parameters needs
    to be returned.

    .PARAMETER NewName
    Specifies the new name of the network adapter.

    .PARAMETER Name
    This is the name of the network adapter to find.

    .PARAMETER PhysicalMediaType
    This is the media type of the network adapter to find.

    .PARAMETER Status
    This is the status of the network adapter to find.

    .PARAMETER MacAddress
    This is the MAC address of the network adapter to find.

    .PARAMETER InterfaceDescription
    This is the interface description of the network adapter to find.

    .PARAMETER InterfaceIndex
    This is the interface index of the network adapter to find.

    .PARAMETER InterfaceGuid
    This is the interface GUID of the network adapter to find.

    .PARAMETER DriverDescription
    This is the driver description of the network adapter.

    .PARAMETER InterfaceNumber
    This is the interface number of the network adapter if more than one
    are returned by the parameters.

    .PARAMETER IgnoreMultipleMatchingAdapters
    This switch will suppress an error occurring if more than one matching
    adapter matches the parameters passed.
#>
function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewName,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $PhysicalMediaType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Up','Disconnected','Disabled')]
        [System.String]
        $Status = 'Up',

        [Parameter()]
        [System.String]
        $MacAddress,

        [Parameter()]
        [System.String]
        $InterfaceDescription,

        [Parameter()]
        [System.UInt32]
        $InterfaceIndex,

        [Parameter()]
        [System.String]
        $InterfaceGuid,

        [Parameter()]
        [System.String]
        $DriverDescription,

        [Parameter()]
        [System.UInt32]
        $InterfaceNumber = 1,

        [Parameter()]
        [System.Boolean]
        $IgnoreMultipleMatchingAdapters = $false
    )

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingNetAdapterNameMessage)
        ) -join '')

    $null = $PSBoundParameters.Remove('NewName')
    try 
    { 
        $adapter = Find-NetworkAdapter `
            @PSBoundParameters `
            -ErrorAction Stop
    }    
    catch
    {
        $PSBoundParameters.Name = $NewName
        $adapter = Find-NetworkAdapter `
            @PSBoundParameters `
            -ErrorAction Stop
    }
    if ($adapter.Name -eq $NewName)
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterNameMatchMessage -f $adapter.Name)
            ) -join '')
        return $true
    }
    else
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.NetAdapterNameNotMatchMessage -f $adapter.Name,$NewName)
            ) -join '')
        return $false
    } # if
} # Test-TargetResource

Export-ModuleMember -function *-TargetResource
