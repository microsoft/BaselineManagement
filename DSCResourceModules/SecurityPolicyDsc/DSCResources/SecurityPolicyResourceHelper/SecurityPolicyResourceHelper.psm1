
<#
    .SYNOPSIS
        Retrieves the localized string data based on the machine's culture.
        Falls back to en-US strings if the machine's culture is not supported.

    .PARAMETER ResourceName
        The name of the resource as it appears before '.strings.psd1' of the localized string file.
        For example:
            AuditPolicySubcategory: MSFT_AuditPolicySubcategory
            AuditPolicyOption: MSFT_AuditPolicyOption
#>
function Get-LocalizedData
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'resource')]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true, ParameterSetName = 'helper')]
        [ValidateNotNullOrEmpty()]
        [String]
        $HelperName

    )

    # With the helper module just update the name and path variables as if it were a resource. 
    if ($PSCmdlet.ParameterSetName -eq 'helper')
    {
        $resourceDirectory = $PSScriptRoot
        $ResourceName = $HelperName
    }
    else 
    {
        # Step up one additional level to build the correct path to the resource culture.
        $resourceDirectory = Join-Path -Path ( Split-Path $PSScriptRoot -Parent ) `
                                       -ChildPath $ResourceName
    }

    $localizedStringFileLocation = Join-Path -Path $resourceDirectory -ChildPath $PSUICulture

    if (-not (Test-Path -Path $localizedStringFileLocation))
    {
        # Fallback to en-US

        $localizedStringFileLocation = Join-Path -Path $resourceDirectory -ChildPath 'en-US'
    }

    Import-LocalizedData `
        -BindingVariable 'localizedData' `
        -FileName "$ResourceName.strings.psd1" `
        -BaseDirectory $localizedStringFileLocation

    return $localizedData
}

<#
    .SYNOPSIS
        Wrapper around secedit.exe used to make changes
    .PARAMETER UserRightsToAddInf
        Inf with desired user rights assignment policy configuration
    .PARAMETER SeceditOutput
        Path to secedit log file output
    .EXAMPLE
        Invoke-Secedit -UserRightsToAddInf C:\secedit.inf -SeceditOutput C:\seceditLog.txt
#>
function Invoke-Secedit
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $UserRightsToAddInf,

        [System.String]
        $SeceditOutput,

        [System.Management.Automation.SwitchParameter]
        $OverWrite
    )

    $script:localizedData = Get-LocalizedData -HelperName 'SecurityPolicyResourceHelper'

    $tempDB = "$env:TEMP\DscSecedit.sdb"
    $arguments = "/configure /db $tempDB /cfg $userRightsToAddInf"

    if ($OverWrite)
    {
        $arguments = $arguments + " /overwrite /quiet"
    }

    Start-Process -FilePath secedit.exe -ArgumentList $arguments -RedirectStandardOutput $seceditOutput -NoNewWindow -Wait
}

<#
    .SYNOPSIS
        Parses Inf produced by 'secedit.exe /export' and returns an object of identites assigned to a user rights assignment policy
    .PARAMETER FilePath
        Path to Inf
    .EXAMPLE
        Get-UserRightsAssignment -FilePath C:\seceditOutput.inf
#>
function Get-UserRightsAssignment
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [System.String]
        $FilePath
    )

    $policyConfiguration = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $policyConfiguration[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $commentCount = $commentCount + 1
            $name = "Comment" + $commentCount
            $policyConfiguration[$section][$name] = $value
        } 
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value =  $matches[1..2] -replace "\*"
            $policyConfiguration[$section][$name] = @(ConvertTo-LocalFriendlyName $($value -split ','))
        }
    }
    return $policyConfiguration
}

<#
    .SYNOPSIS
        Converts SID to friendly name
    .PARAMETER SID
        SID of identity being converted
    .EXAMPLE
        ConvertTo-LocalFriendlyName -SID 'S-1-5-21-3623811015-3361044348-30300820-1013'
#>
function ConvertTo-LocalFriendlyName
{
    [OutputType([String[]])]
    [CmdletBinding()]
    param
    (
        [System.String[]]
        $SID        
    )
    
    $localizedData = Get-LocalizedData -HelperName 'SecurityPolicyResourceHelper'
    $domainRole = (Get-WmiObject -Class Win32_ComputerSystem).DomainRole
    $friendlyNames = [String[]]@()
    foreach ($id in $SID)
    {        
        if ($null -ne $id -and $id -match 'S-')
        {
            try
            {
                $securityIdentifier = [System.Security.Principal.SecurityIdentifier]($id.trim())
                $user = $securityIdentifier.Translate([System.Security.Principal.NTAccount])
                $friendlyNames += $user.value
            }
            catch
            {
                Write-Warning -Message ($localizedData.ErrorCantTranslateSID -f $id, $($_.Exception.Message) )
            }
        }
        elseIf ($domainRole -eq 4 -or $domainRole -eq 5)
        {
            $friendlyNames += "$($env:USERDOMAIN + '\' + $($id.trim()))"
        }
        elseIf ($id -notmatch '^S-')
        {
            $friendlyNames += "$($id.trim())"
        }
    }

    return $friendlyNames
}

