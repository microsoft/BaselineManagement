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
    -ResourceName 'MSFT_xIPAddress' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current state of an IP address assigned to an interface.

    .PARAMETER IPAddress
    The desired IP address.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the IP address should be set.

    .PARAMETER PrefixLength
    The prefix length of the IP Address.

    .PARAMETER AddressFamily
    IP address family.
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
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [uInt32]
        $PrefixLength = 16,

        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily = 'IPv4'
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingIPAddressMessage)
        ) -join '')

    $CurrentIPAddress = Get-NetIPAddress `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily

    $returnValue = @{
        IPAddress      = [System.String]::Join(', ',$CurrentIPAddress.IPAddress)
        PrefixLength     = [System.String]::Join(', ',$CurrentIPAddress.PrefixLength)
        AddressFamily  = $AddressFamily
        InterfaceAlias = $InterfaceAlias
    }

    $returnValue
}

<#
    .SYNOPSIS
    Sets an IP address on an interface.

    .PARAMETER IPAddress
    The desired IP address.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the IP address should be set.

    .PARAMETER PrefixLength
    The prefix length of the IP Address.

    .PARAMETER AddressFamily
    IP address family.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [uInt32]
        $PrefixLength,

        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily = 'IPv4'
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingIPAddressMessage)
        ) -join '')

    # Use $AddressFamily to select the IPv4 or IPv6 destination prefix
    $DestinationPrefix = '0.0.0.0/0'
    if ($AddressFamily -eq 'IPv6')
    {
        $DestinationPrefix = '::/0'
    }

    # Get all the default routes - this has to be done in case the IP Address is
    # beng Removed
    $defaultRoutes = @(Get-NetRoute `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily `
        -ErrorAction Stop).Where( { $_.DestinationPrefix -eq $DestinationPrefix } )

    # Remove any default routes on the specified interface -- it is important to do
    # this *before* removing the IP address, particularly in the case where the IP
    # address was auto-configured by DHCP
    if ($defaultRoutes)
    {
        foreach ($defaultRoute in $defaultRoutes) {
            Remove-NetRoute `
                -DestinationPrefix $defaultRoute.DestinationPrefix `
                -NextHop $defaultRoute.NextHop `
                -InterfaceIndex $defaultRoute.InterfaceIndex `
                -AddressFamily $defaultRoute.AddressFamily `
                -Confirm:$false `
                -ErrorAction Stop
        }
    }

    # Get the current IP Address based on the parameters given.
    $currentIPs = @(Get-NetIPAddress `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily `
        -ErrorAction Stop)

    # Remove any IP addresses on the specified interface
    if ($currentIPs)
    {
        foreach ($CurrentIP in $CurrentIPs) {
            Remove-NetIPAddress `
                -IPAddress $CurrentIP.IPAddress `
                -InterfaceIndex $CurrentIP.InterfaceIndex `
                -AddressFamily $CurrentIP.AddressFamily `
                -Confirm:$false `
                -ErrorAction Stop
        }
    }

    # Build parameter hash table
    $Parameters = @{
        IPAddress = $IPAddress
        PrefixLength = $PrefixLength
        InterfaceAlias = $InterfaceAlias
    }

    # Apply the specified IP configuration
    $null = New-NetIPAddress @Parameters -ErrorAction Stop

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.IPAddressSetStateMessage)
        ) -join '' )
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests the IP address on the interface.

    .PARAMETER IPAddress
    The desired IP address.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the IP address should be set.

    .PARAMETER PrefixLength
    The prefix length of the IP Address.

    .PARAMETER AddressFamily
    IP address family.
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
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [uInt32]
        $PrefixLength = 16,

        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily = 'IPv4'
    )

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingIPAddressMessage)
        ) -join '')

    Assert-ResourceProperty @PSBoundParameters

    # Get the current IP Address based on the parameters given.
     # First make sure that adapter is available
    [Boolean] $adapterBindingReady = $false
    [DateTime] $startTime = Get-Date

    while (-not $adapterBindingReady -and (((Get-Date) - $startTime).TotalSeconds) -lt 30)
    {
        $currentIPs = @(Get-NetIPAddress `
            -InterfaceAlias $InterfaceAlias `
            -AddressFamily $AddressFamily `
            -ErrorAction SilentlyContinue)
        if ($currentIPs)
        {
            $adapterBindingReady = $true
        }
        else
        {
            Start-Sleep -Milliseconds 200
        }
    } # while

    # Test if the IP Address passed is present
    if ($IPAddress -notin $currentIPs.IPAddress)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.IPAddressDoesNotMatchMessage) -f $IPAddress,$currentIPs.IPAddress
            ) -join '' )
        $desiredConfigurationMatch = $false
    }
    else
    {
        Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
            $($LocalizedData.IPAddressMatchMessage)
            ) -join '')

        # Filter the IP addresses for the IP address to check
        $filterIP = $currentIPs.Where( { $_.IPAddress -eq $IPAddress } )

        # Only test the Prefix Length if the IP address is present
        if (-not $filterIP.PrefixLength.Equals([byte]$PrefixLength))
        {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.PrefixLengthDoesNotMatchMessage) -f $PrefixLength,$currentIPs.PrefixLength
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
                $($LocalizedData.PrefixLengthMatchMessage)
                ) -join '' )
        }
    }
    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
    Check the IP Address details are valid and do not conflict with Address family.
    Also checks the prefix length and ensures the interface exists.
    If any problems are detected an exception will be thrown.

    .PARAMETER IPAddress
    The desired IP address.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the IP address should be set.

    .PARAMETER PrefixLength
    The prefix length of the IP Address.

    .PARAMETER AddressFamily
    IP address family.
#>
function Assert-ResourceProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InterfaceAlias,

        [uInt32]
        $PrefixLength = 16,

        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily = 'IPv4'
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
    if (-not ([System.Net.Ipaddress]::TryParse($IPAddress, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $IPAddress
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress]$IPAddress).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $IPAddress,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6.ToString()) `
        -and ($AddressFamily -ne 'IPv6'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $IPAddress,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    if ((
            ($AddressFamily -eq 'IPv4') `
                -and (($PrefixLength -lt [uint32]0) -or ($PrefixLength -gt [uint32]32))
            ) -or (
            ($AddressFamily -eq 'IPv6') `
                -and (($PrefixLength -lt [uint32]0) -or ($PrefixLength -gt [uint32]128))
        ))
    {
        $errorId = 'PrefixLengthError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.PrefixLengthError) -f $PrefixLength,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
} # Assert-ResourceProperty

Export-ModuleMember -function *-TargetResource
