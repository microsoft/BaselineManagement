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
    -ResourceName 'MSFT_xRoute' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current state of a Route for an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface.

    .PARAMETER AddressFamily
    Specify the IP address family.

    .PARAMETER DestinationPrefix
    Specifies a destination prefix of an IP route.
    A destination prefix consists of an IP address prefix and a prefix length, separated by a slash (/).

    .PARAMETER NextHop
    Specifies the next hop for the IP route.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateSet('IPv4', 'IPv6')]
        [String] $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPrefix,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $NextHop
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingRouteMessage) `
            -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
        ) -join '' )

    # Lookup the existing Route
    $route = Get-Route @PSBoundParameters

    $returnValue = @{
        InterfaceAlias    = $InterfaceAlias
        AddressFamily     = $AddressFamily
        DestinationPrefix = $DestinationPrefix
        NextHop           = $NextHop
    }
    if ($route)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.RouteExistsMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        $returnValue += @{
            Ensure            = 'Present'
            RouteMetric       = [Uint16] $route.RouteMetric
            Publish           = $route.Publish
            PreferredLifetime = [Double] $route.PreferredLifetime.TotalSeconds
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.RouteDoesNotExistMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }

    $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    Sets a Route for an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface.

    .PARAMETER AddressFamily
    Specify the IP address family.

    .PARAMETER DestinationPrefix
    Specifies a destination prefix of an IP route.
    A destination prefix consists of an IP address prefix and a prefix length, separated by a slash (/).

    .PARAMETER NextHop
    Specifies the next hop for the IP route.

    .PARAMETER Ensure
    Specifies whether the route should exist.

    .PARAMETER RouteMetric
    Specifies an integer route metric for an IP route.

    .PARAMETER Publish
    Specifies the publish setting of an IP route.

    .PARAMETER PreferredLifetime
    Specifies a preferred lifetime in seconds of an IP route.
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
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DestinationPrefix,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Uint16]
        $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String]
        $Publish = 'No',

        [Double]
        $PreferredLifetime
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing Route
    $route = Get-Route @PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureRouteExistsMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        if ($route)
        {
            # The Route exists - update it
            Set-NetRoute @PSBoundParameters `
                -Confirm:$false `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.RouteUpdatedMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        }
        else
        {
            # The Route does not exit - create it
            New-NetRoute @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.RouteCreatedMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureRouteDoesNotExistMessage) `
                -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
            ) -join '' )

        if ($route)
        {
            <#
            The Route exists - remove it
            Use the parameters passed to Set-TargetResource to delete the appropriate route.
            Clear the Publish and PreferredLifetime parameters so they aren't passed to the
            Remove-NetRoute cmdlet.
            #>

            $null = $PSBoundParameters.Remove('Publish')
            $null = $PSBoundParameters.Remove('PreferredLifetime')

            Remove-NetRoute @PSBoundParameters `
                -Confirm:$false `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.RouteRemovedMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests the state of a Route on an interface.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface.

    .PARAMETER AddressFamily
    Specify the IP address family.

    .PARAMETER DestinationPrefix
    Specifies a destination prefix of an IP route.
    A destination prefix consists of an IP address prefix and a prefix length, separated by a slash (/).

    .PARAMETER NextHop
    Specifies the next hop for the IP route.

    .PARAMETER Ensure
    Specifies whether the route should exist.

    .PARAMETER RouteMetric
    Specifies an integer route metric for an IP route.

    .PARAMETER Publish
    Specifies the publish setting of an IP route.

    .PARAMETER PreferredLifetime
    Specifies a preferred lifetime in seconds of an IP route.
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
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DestinationPrefix,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Uint16]
        $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String]
        $Publish = 'No',

        [Double]
        $PreferredLifetime
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingRouteMessage) `
           -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
        ) -join '' )

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Check the parameters
    Assert-ResourceProperty @PSBoundParameters

    # Lookup the existing Route
    $route = Get-Route @PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        # The route should exist
        if ($route)
        {
            # The route exists and does - but check the parameters
            if (($PSBoundParameters.ContainsKey('RouteMetric')) `
                -and ($route.RouteMetric -ne $RouteMetric))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.RoutePropertyNeedsUpdateMessage) `
                       -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop,'RouteMetric' `
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Publish')) `
                -and ($route.Publish -ne $Publish))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.RoutePropertyNeedsUpdateMessage) `
                       -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop,'Publish' `
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('PreferredLifetime')) `
                -and ($route.PreferredLifetime.TotalSeconds -ne $PreferredLifetime))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.RoutePropertyNeedsUpdateMessage) `
                       -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop,'PreferredLifetime' `
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # The route doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.RouteDoesNotExistButShouldMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The route should not exist
        if ($route)
        {
            # The route exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.RouteExistsButShouldNotMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The route does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.RouteDoesNotExistAndShouldNotMessage) `
                    -f $AddressFamily,$InterfaceAlias,$DestinationPrefix,$NextHop `
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
    This function looks up the route using the parameters and returns
    it. If the route is not found $null is returned.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface.

    .PARAMETER AddressFamily
    Specify the IP address family.

    .PARAMETER DestinationPrefix
    Specifies a destination prefix of an IP route.
    A destination prefix consists of an IP address prefix and a prefix length, separated by a slash (/).

    .PARAMETER NextHop
    Specifies the next hop for the IP route.

    .PARAMETER Ensure
    Specifies whether the route should exist.

    .PARAMETER RouteMetric
    Specifies an integer route metric for an IP route.

    .PARAMETER Publish
    Specifies the publish setting of an IP route.

    .PARAMETER PreferredLifetime
    Specifies a preferred lifetime in seconds of an IP route.

#>
Function Get-Route
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
        [ValidateNotNullOrEmpty()]
        [String]
        $DestinationPrefix,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Uint16]
        $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String]
        $Publish = 'No',

        [Double]
        $PreferredLifetime
    )

    try
    {
        $route = Get-NetRoute `
            -InterfaceAlias $InterfaceAlias `
            -AddressFamily $AddressFamily `
            -DestinationPrefix $DestinationPrefix `
            -NextHop $NextHop `
            -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $route = $null
    }
    catch
    {
        Throw $_
    }
    Return $route
}

<#
    .SYNOPSIS
    This function validates the parameters passed. Called by Test-Resource.
    Will throw an error if any parameters are invalid.

    .PARAMETER InterfaceAlias
    Specifies the alias of a network interface.

    .PARAMETER AddressFamily
    Specify the IP address family.

    .PARAMETER DestinationPrefix
    Specifies a destination prefix of an IP route.
    A destination prefix consists of an IP address prefix and a prefix length, separated by a slash (/).

    .PARAMETER NextHop
    Specifies the next hop for the IP route.

    .PARAMETER Ensure
    Specifies whether the route should exist.

    .PARAMETER RouteMetric
    Specifies an integer route metric for an IP route.

    .PARAMETER Publish
    Specifies the publish setting of an IP route.

    .PARAMETER PreferredLifetime
    Specifies a preferred lifetime in seconds of an IP route.
#>
Function Assert-ResourceProperty
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
        [ValidateNotNullOrEmpty()]
        [String]
        $DestinationPrefix,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NextHop,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Uint16]
        $RouteMetric = 256,

        [ValidateSet('No', 'Yes', 'Age')]
        [String]
        $Publish = 'No',

        [Double]
        $PreferredLifetime
    )

    # Validate the Adapter exists
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

    # Validate the DestinationPrefix Parameter
    $Components = $DestinationPrefix -split '/'
    $Prefix = $Components[0]
    $Subnet = $Components[1]

    if (-not ([System.Net.Ipaddress]::TryParse($Prefix, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $Prefix
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress] $Prefix).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $Prefix,$AddressFamily
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
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $Prefix,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # Validate the NextHop Parameter
    if (-not ([System.Net.Ipaddress]::TryParse($NextHop, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $NextHop
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress] $NextHop).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $NextHop,$AddressFamily
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
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $NextHop,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}

Export-ModuleMember -Function *-TargetResource
