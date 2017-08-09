#requires -Version 4.0

Set-StrictMode -Version Latest

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Path,

        [Parameter(Mandatory = $false)]
        [Boolean]
        $Enabled = $true,

        [Parameter(Mandatory = $false)]
        [Boolean]
        $PreserveInherited = $true
    )

    $PSBoundParameters.GetEnumerator() |
    ForEach-Object -Begin {
        $Width = $PSBoundParameters.Keys.Length | Sort-Object | Select-Object -Last 1
    } -Process {
        "{0,-$($Width)} : '{1}'" -f $_.Key, ($_.Value -join ', ') |
        Write-Verbose
    }

    $Acl = Get-Acl -Path $Path -ErrorAction Stop

    $EnabledResult = $Acl.AreAccessRulesProtected -eq $false

    if ($EnabledResult -eq $true)
    {
        Write-Verbose -Message "Permissions inheritance is enabled on path '$Path'."
    }
    else
    {
        Write-Verbose -Message "Permissions inheritance is disabled on path '$Path'."
    }

    $ReturnValue = @{
        Path = $Path
        Enabled = $EnabledResult
        PreserveInherited = $PreserveInherited
    }

    return $ReturnValue
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Path,

        [Parameter(Mandatory = $false)]
        [Boolean]
        $Enabled = $true,

        [Parameter(Mandatory = $false)]
        [Boolean]
        $PreserveInherited = $true
    )

    $TargetResource = Get-TargetResource @PSBoundParameters

    $InDesiredState = $Enabled -eq $TargetResource.Enabled

    if ($InDesiredState -eq $true)
    {
        Write-Verbose -Message 'The target resource is already in the desired state. No action is required.'
    }
    else
    {
        Write-Verbose -Message 'The target resource is not in the desired state.'
    }

    return $InDesiredState
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Path,

        [Parameter(Mandatory = $false)]
        [Boolean]
        $Enabled = $true,

        [Parameter(Mandatory = $false)]
        [Boolean]
        $PreserveInherited = $true
    )

    $Acl = Get-Acl -Path $Path -ErrorAction Stop

    if ($Enabled -eq $false)
    {
        Write-Verbose -Message "Disabling permissions inheritance on path '$Path'."

        if ($PreserveInherited -eq $true)
        {
            Write-Verbose -Message 'Inherited permissions will be converted into explicit permissions.'
        }
        else
        {
            Write-Verbose -Message 'Inherited permissions will be removed.'
        }

        $Acl.SetAccessRuleProtection($true, $PreserveInherited)
    }
    else
    {
        Write-Verbose -Message "Enabling permissions inheritance on path '$Path'."

        $Acl.SetAccessRuleProtection($false, $false)
    }

    Set-FileSystemAccessControl -Path $Path -Acl $Acl
}

#region Helper Functions

function Set-FileSystemAccessControl
{
    <#
    .SYNOPSIS
        Applies access control entries (ACEs) to the specified file or directory.

    .DESCRIPTION
        The Set-FileSystemAccessControl function applies access control entries (ACEs) to the specified file or directory.

    .PARAMETER Path
        Specifies the path to the file or directory.

    .PARAMETER Acl
        Specifies the access control list (ACL) object with the desired access control entries (ACEs)
        to apply to the file or directory described by the Path parameter.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.AccessControl.FileSystemSecurity]
        $Acl
    )

    $PathInfo = Resolve-Path -Path $Path -ErrorAction Stop

    if ($PSCmdlet.ShouldProcess($Path))
    {
        if ($Acl -is [System.Security.AccessControl.DirectorySecurity])
        {
            [System.IO.Directory]::SetAccessControl($PathInfo.ProviderPath, $Acl)
        }
        else
        {
            [System.IO.File]::SetAccessControl($PathInfo.ProviderPath, $Acl)
        }
    }
}

#endregion
