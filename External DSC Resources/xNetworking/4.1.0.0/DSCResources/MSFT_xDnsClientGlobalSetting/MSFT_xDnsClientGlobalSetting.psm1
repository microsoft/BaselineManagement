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
    -ResourceName 'MSFT_xDnsClientGlobalSetting' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    This is an array of all the parameters used by this resource.
#>
$script:resourceData = Import-LocalizedData `
    -BaseDirectory $PSScriptRoot `
    -FileName 'MSFT_xDnsClientGlobalSetting.data.psd1'
$script:parameterList = $script:resourceData.ParameterList

<#
    .SYNOPSIS
    Returns the current DNS Client Global Settings.

    .PARAMETER IsSingleInstance
    Specifies the resource is a single instance, the value must be 'Yes'.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.GettingDnsClientGlobalSettingsMessage)
        ) -join '' )

    # Get the current Dns Client Global Settings
    $dnsClientGlobalSetting = Get-DnsClientGlobalSetting `
        -ErrorAction Stop

    # Generate the return object.
    $returnValue = @{
        IsSingleInstance = 'Yes'
    }
    foreach ($parameter in $script:parameterList)
    {
        $returnValue += @{ $parameter.Name = $dnsClientGlobalSetting.$($parameter.name) }
    } # foreach

    return $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    Sets the DNS Client Global Settings.

    .PARAMETER IsSingleInstance
    Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER SuffixSearchList
    Specifies a list of global suffixes that can be used in the specified order by the DNS client
    for resolving the IP address of the computer name.

    .PARAMETER UseDevolution.
    Specifies that devolution is activated.

    .PARAMETER DevolutionLevel
    Specifies the number of labels up to which devolution should occur.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [String[]]
        $SuffixSearchList,

        [Boolean]
        $UseDevolution,

        [Uint32]
        $DevolutionLevel
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingDnsClientGlobalSettingMessage)
        ) -join '' )

    # Get the current Dns Client Global Settings
    $dnsClientGlobalSetting = Get-DnsClientGlobalSetting `
        -ErrorAction Stop

    # Generate a list of parameters that will need to be changed.
    $changeParameters = @{}
    foreach ($parameter in $script:parameterList)
    {
        $parameterSource = $dnsClientGlobalSetting.$($parameter.name)
        $parameterNew = (Get-Variable -Name ($parameter.name)).Value
        if ($PSBoundParameters.ContainsKey($parameter.Name) `
            -and (Compare-Object -ReferenceObject $parameterSource -DifferenceObject $parameterNew -SyncWindow 0))
        {
            $changeParameters += @{
                $($parameter.name) = $parameterNew
            }
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DnsClientGlobalSettingUpdateParameterMessage) `
                    -f $parameter.Name,$parameterNew
                ) -join '' )
        } # if
    } # foreach
    if ($changeParameters.Count -gt 0)
    {
        # Update any parameters that were identified as different
        $null = Set-DnsClientGlobalSetting `
            @ChangeParameters `
            -ErrorAction Stop

        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.DnsClientGlobalSettingUpdatedMessage)
            ) -join '' )
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests the state of DNS Client Global Settings.

    .PARAMETER IsSingleInstance
    Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER SuffixSearchList
    Specifies a list of global suffixes that can be used in the specified order by the DNS client
    for resolving the IP address of the computer name.

    .PARAMETER UseDevolution.
    Specifies that devolution is activated.

    .PARAMETER DevolutionLevel
    Specifies the number of labels up to which devolution should occur.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [String[]]
        $SuffixSearchList,

        [Boolean]
        $UseDevolution,

        [Uint32]
        $DevolutionLevel
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestingDnsClientGlobalSettingMessage)
        ) -join '' )

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    # Get the current Dns Client Global Settings
    $DnsClientGlobalSetting = Get-DnsClientGlobalSetting `
        -ErrorAction Stop

    # Check each parameter
    foreach ($parameter in $script:parameterList)
    {
        $parameterSource = $DnsClientGlobalSetting.$($parameter.name)
        $parameterNew = (Get-Variable -Name ($parameter.name)).Value
        if ($PSBoundParameters.ContainsKey($parameter.Name) `
            -and (Compare-Object -ReferenceObject $parameterSource -DifferenceObject $parameterNew -SyncWindow 0)) {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.DnsClientGlobalSettingParameterNeedsUpdateMessage) `
                    -f $parameter.Name,$parameterSource,$parameterNew
                ) -join '' )
            $desiredConfigurationMatch = $false
        } # if
    } # foreach

    return $desiredConfigurationMatch
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
