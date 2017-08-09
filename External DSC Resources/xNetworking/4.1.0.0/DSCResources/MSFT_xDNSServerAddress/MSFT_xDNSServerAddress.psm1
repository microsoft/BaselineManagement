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
    -ResourceName 'MSFT_xDNSServerAddress' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current DNS Server Addresses for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER Address
    The desired DNS Server address(es).
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
        [ValidateSet('IPv4', 'IPv6')]
        [String]
        $AddressFamily,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Address
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingDNSServerAddressesMessage)
        ) -join '')

    $returnValue = @{
        Address = (Get-DnsClientServerAddress `
            -InterfaceAlias $InterfaceAlias `
            -AddressFamily $AddressFamily).ServerAddresses
        AddressFamily = $AddressFamily
        InterfaceAlias = $InterfaceAlias
    }

    return $returnValue
}

<#
    .SYNOPSIS
    Sets the DNS Server Address for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER Address
    The desired DNS Server address(es).

    .PARAMETER Validate
    Requires that the DNS Server addresses be validated if they are updated.
    It will cause the resouce to throw a 'A general error occurred that is not covered by a more
    specific error code.' error if set to True and specified DNS Servers are not accessible.
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
        [String[]]
        $Address,

        [Boolean]
        $Validate = $false
    )

    Write-Verbose -Message ( @("$($MyInvocation.MyCommand): "
        $($LocalizedData.ApplyingDNSServerAddressesMessage)
        ) -join '')

    #Get the current DNS Server Addresses based on the parameters given.
    $PSBoundParameters.Remove('Address')
    $PSBoundParameters.Remove('Validate')
    $currentAddress = (Get-DnsClientServerAddress @PSBoundParameters `
        -ErrorAction Stop).ServerAddresses

    #Check if the Server addresses are the same as the desired addresses.
    [Boolean] $addressDifferent = (@(Compare-Object `
            -ReferenceObject $currentAddress `
            -DifferenceObject $Address `
            -SyncWindow 0).Length -gt 0)

    if ($addressDifferent)
    {
        # Set the DNS settings as well
        $Splat = @{
            InterfaceAlias = $InterfaceAlias
            Address = $Address
            Validate = $Validate
        }
        Set-DnsClientServerAddress @Splat `
            -ErrorAction Stop

        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersHaveBeenSetCorrectlyMessage)
            ) -join '' )
    }
    else
    {
        #Test will return true in this case
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersAlreadySetMessage)
            ) -join '' )
    }
}

<#
    .SYNOPSIS
    Tests the current state of a DNS Server Address for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER Address
    The desired DNS Server address(es).

    .PARAMETER Validate
    Requires that the DNS Server addresses be validated if they are updated.
    It will cause the resouce to throw a 'A general error occurred that is not covered by a more
    specific error code.' error if set to True and specified DNS Servers are not accessible.
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
        [String[]]
        $Address,

        [Boolean]
        $Validate = $false
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.CheckingDNSServerAddressesMessage)
        ) -join '' )

    #Validate the Settings passed
    Foreach ($ServerAddress in $Address) {
        Assert-ResourceProperty `
            -Address $ServerAddress `
            -AddressFamily $AddressFamily `
            -InterfaceAlias $InterfaceAlias
    }

    #Get the current DNS Server Addresses based on the parameters given.
    $currentAddress = (Get-DnsClientServerAddress `
        -InterfaceAlias $InterfaceAlias `
        -AddressFamily $AddressFamily `
        -ErrorAction Stop).ServerAddresses

    #Check if the Server addresses are the same as the desired addresses.
    [Boolean] $addressDifferent = (@(Compare-Object `
            -ReferenceObject $currentAddress `
            -DifferenceObject $Address `
            -SyncWindow 0).Length -gt 0)

    if ($addressDifferent)
    {
        $desiredConfigurationMatch = $false
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersNotCorrectMessage) `
                -f ($Address -join ','),($currentAddress -join ',')
            ) -join '' )
    }
    else
    {
        #Test will return true in this case
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.DNSServersSetCorrectlyMessage)
            ) -join '' )
    }
    return $desiredConfigurationMatch
}

<#
    .SYNOPSIS
    Checks the Address details are valid and do not conflict with Address family.
    Ensures interface exists. If any problems are detected an exception will be thrown.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER AddressFamily
    IP address family.

    .PARAMETER Address
    The desired DNS Server address.
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
        [ValidateNotNullOrEmpty()]
        [String]
        $Address
    )

    if ( -not (Get-NetAdapter | Where-Object -Property Name -EQ $InterfaceAlias ))
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

    if ( -not ([System.Net.IPAddress]::TryParse($Address, [ref]0)))
    {
        $errorId = 'AddressFormatError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressFormatError) -f $Address
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $detectedAddressFamily = ([System.Net.IPAddress]$Address).AddressFamily.ToString()
    if (($detectedAddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString()) `
        -and ($AddressFamily -ne 'IPv4'))
    {
        $errorId = 'AddressMismatchError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $Address,$AddressFamily
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
        $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $Address,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
} # Assert-ResourceProperty

Export-ModuleMember -function *-TargetResource
