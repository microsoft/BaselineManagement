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
    -ResourceName 'MSFT_xDnsConnectionSuffix' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current DNS Connection Suffix for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER ConnectionSpecificSuffix
    DNS connection-specific suffix to assign to the network interface.

    .PARAMETER RegisterThisConnectionsAddress
    Specifies that the IP address for this connection is to be registered.

    .PARAMETER UseSuffixWhenRegistering
    Specifies that this host name and the connection specific suffix for this connection are to
    be registered.

    .PARAMETER Ensure
    Ensure that the network interface connection-specific suffix is present or not.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionSpecificSuffix,

        [System.Boolean]
        $RegisterThisConnectionsAddress = $true,

        [System.Boolean]
        $UseSuffixWhenRegistering = $false,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $dnsClient = Get-DnsClient -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue
    $targetResource = @{
        InterfaceAlias                 = $dnsClient.InterfaceAlias
        ConnectionSpecificSuffix       = $dnsClient.ConnectionSpecificSuffix
        RegisterThisConnectionsAddress = $dnsClient.RegisterThisConnectionsAddress
        UseSuffixWhenRegistering       = $dnsClient.UseSuffixWhenRegistering
    }
    if ($Ensure -eq 'Present')
    {
        ## Test to see if the connection-specific suffix matches
        Write-Verbose -Message ($LocalizedData.CheckingConnectionSuffix -f $ConnectionSpecificSuffix)
        if ($dnsClient.ConnectionSpecificSuffix -eq $ConnectionSpecificSuffix)
        {
            $Ensure = 'Present'
        }
        else
        {
            $Ensure = 'Absent'
        }
    }
    else
    {
        ## ($Ensure -eq 'Absent'). Test to see if there is a connection-specific suffix
        Write-Verbose -Message ($LocalizedData.CheckingConnectionSuffix -f '')
        if ([System.String]::IsNullOrEmpty($dnsClient.ConnectionSpecificSuffix))
        {
            $Ensure = 'Absent'
        }
        else
        {
            $Ensure = 'Present'
        }
    }
    $targetResource['Ensure'] = $Ensure
    return $targetResource
}

<#
    .SYNOPSIS
    Sets the DNS Connection Suffix for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER ConnectionSpecificSuffix
    DNS connection-specific suffix to assign to the network interface.

    .PARAMETER RegisterThisConnectionsAddress
    Specifies that the IP address for this connection is to be registered.

    .PARAMETER UseSuffixWhenRegistering
    Specifies that this host name and the connection specific suffix for this connection are to
    be registered.

    .PARAMETER Ensure
    Ensure that the network interface connection-specific suffix is present or not.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionSpecificSuffix,

        [System.Boolean]
        $RegisterThisConnectionsAddress = $true,

        [System.Boolean]
        $UseSuffixWhenRegistering = $false,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $setDnsClientParams = @{
        InterfaceAlias = $InterfaceAlias
        RegisterThisConnectionsAddress = $RegisterThisConnectionsAddress
        UseSuffixWhenRegistering = $UseSuffixWhenRegistering
    }
    if ($Ensure -eq 'Present')
    {
        $setDnsClientParams['ConnectionSpecificSuffix'] = $ConnectionSpecificSuffix
        Write-Verbose -Message ($LocalizedData.SettingConnectionSuffix `
            -f $ConnectionSpecificSuffix, $InterfaceAlias)
    }
    else
    {
        $setDnsClientParams['ConnectionSpecificSuffix'] = ''
        Write-Verbose -Message ($LocalizedData.RemovingConnectionSuffix `
            -f $ConnectionSpecificSuffix, $InterfaceAlias)
    }
    Set-DnsClient @setDnsClientParams
}

<#
    .SYNOPSIS
    Tests the current state of a DNS Connection Suffix for an interface.

    .PARAMETER InterfaceAlias
    Alias of the network interface for which the DNS server address is set.

    .PARAMETER ConnectionSpecificSuffix
    DNS connection-specific suffix to assign to the network interface.

    .PARAMETER RegisterThisConnectionsAddress
    Specifies that the IP address for this connection is to be registered.

    .PARAMETER UseSuffixWhenRegistering
    Specifies that this host name and the connection specific suffix for this connection are to
    be registered.

    .PARAMETER Ensure
    Ensure that the network interface connection-specific suffix is present or not.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InterfaceAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionSpecificSuffix,

        [System.Boolean]
        $RegisterThisConnectionsAddress = $true,

        [System.Boolean]
        $UseSuffixWhenRegistering = $false,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters
    $inDesiredState = $true
    if ($targetResource.Ensure -ne $Ensure)
    {
        Write-Verbose -Message ($LocalizedData.PropertyMismatch `
            -f 'Ensure', $Ensure, $targetResource.Ensure)
        $inDesiredState = $false
    }
    if ($targetResource.RegisterThisConnectionsAddress -ne $RegisterThisConnectionsAddress)
    {
        Write-Verbose -Message ($LocalizedData.PropertyMismatch `
            -f 'RegisterThisConnectionsAddress', $RegisterThisConnectionsAddress, $targetResource.RegisterThisConnectionsAddress)
        $inDesiredState = $false
    }
    if ($targetResource.UseSuffixWhenRegistering -ne $UseSuffixWhenRegistering)
    {
        Write-Verbose -Message ($LocalizedData.PropertyMismatch `
            -f 'UseSuffixWhenRegistering', $UseSuffixWhenRegistering, $targetResource.UseSuffixWhenRegistering)
        $inDesiredState = $false
    }
    if ($inDesiredState)
    {
        Write-Verbose -Message $LocalizedData.ResourceInDesiredState
    }
    else
    {
        Write-Verbose -Message $LocalizedData.ResourceNotInDesiredState
    }
    return $inDesiredState
}

Export-ModuleMember -function *-TargetResource
