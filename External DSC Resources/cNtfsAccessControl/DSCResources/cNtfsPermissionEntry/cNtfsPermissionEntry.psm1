#requires -Version 4.0 -Modules CimCmdlets

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

        [Parameter(Mandatory = $true)]
        [String]
        $Principal
    )

    $Acl = Get-Acl -Path $Path -ErrorAction Stop

    if ($Acl -is [System.Security.AccessControl.DirectorySecurity])
    {
        $ItemType = 'Directory'
    }
    else
    {
        $ItemType = 'File'
    }

    $Identity = Resolve-IdentityReference -Identity $Principal -ErrorAction Stop

    [System.Security.AccessControl.FileSystemAccessRule[]]$AccessRules = @(
        $Acl.Access |
        Where-Object -FilterScript {
            ($_.IsInherited -eq $false) -and
            ($_.IdentityReference -eq $Identity.Name)
        }
    )

    Write-Verbose -Message "Current permission entry count : $($AccessRules.Count)"

    $CimAccessRules = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

    if ($AccessRules.Count -eq 0)
    {
        $EnsureResult = 'Absent'
    }
    else
    {
        $EnsureResult = 'Present'

        $AccessRules |
        ConvertFrom-FileSystemAccessRule -ItemType $ItemType |
        ForEach-Object -Process {

            $CimAccessRule = New-CimInstance -ClientOnly `
                -Namespace root/Microsoft/Windows/DesiredStateConfiguration `
                -ClassName cNtfsAccessControlInformation `
                -Property @{
                    AccessControlType = $_.AccessControlType
                    FileSystemRights = $_.FileSystemRights
                    Inheritance = $_.Inheritance
                    NoPropagateInherit = $_.NoPropagateInherit
                }

            $CimAccessRules.Add($CimAccessRule)

        }
    }

    $ReturnValue = @{
        Ensure = $EnsureResult
        Path = $Path
        ItemType = $ItemType
        Principal = $Principal
        AccessControlInformation = [Microsoft.Management.Infrastructure.CimInstance[]]@($CimAccessRules)
    }

    return $ReturnValue
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [String]
        $Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Directory', 'File')]
        [String]
        $ItemType,

        [Parameter(Mandatory = $true)]
        [String]
        $Principal,

        [Parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlInformation
    )

    $PSBoundParameters.GetEnumerator() |
    ForEach-Object -Begin {
        $Width = $PSBoundParameters.Keys.Length | Sort-Object | Select-Object -Last 1
    } -Process {
        "{0,-$($Width)} : '{1}'" -f $_.Key, ($_.Value -join ', ') |
        Write-Verbose
    }

    if ($PSBoundParameters.ContainsKey('ItemType'))
    {
        Write-Verbose -Message 'The ItemType property is deprecated and will be ignored.'
    }

    $InDesiredState = $true

    $Acl = Get-Acl -Path $Path -ErrorAction Stop

    if ($Acl -is [System.Security.AccessControl.DirectorySecurity])
    {
        $ItemType = 'Directory'
    }
    else
    {
        $ItemType = 'File'
    }

    $Identity = Resolve-IdentityReference -Identity $Principal -ErrorAction Stop

    [System.Security.AccessControl.FileSystemAccessRule[]]$AccessRules = @(
        $Acl.Access |
        Where-Object -FilterScript {
            ($_.IsInherited -eq $false) -and
            ($_.IdentityReference -eq $Identity.Name)
        }
    )

    Write-Verbose -Message "Current permission entry count : $($AccessRules.Count)"

    [PSCustomObject[]]$ReferenceRuleInfo = @()

    if ($PSBoundParameters.ContainsKey('AccessControlInformation'))
    {
        foreach ($Instance in $AccessControlInformation)
        {
            $AccessControlType = $Instance.CimInstanceProperties.Where({$_.Name -eq 'AccessControlType'}).ForEach({$_.Value})
            $FileSystemRights = $Instance.CimInstanceProperties.Where({$_.Name -eq 'FileSystemRights'}).ForEach({$_.Value})
            $Inheritance = $Instance.CimInstanceProperties.Where({$_.Name -eq 'Inheritance'}).ForEach({$_.Value})
            $NoPropagateInherit = $Instance.CimInstanceProperties.Where({$_.Name -eq 'NoPropagateInherit'}).ForEach({$_.Value})

            if (-not $AccessControlType)
            {
                $AccessControlType = 'Allow'
            }

            if (-not $FileSystemRights)
            {
                $FileSystemRights = 'ReadAndExecute'
            }

            if (-not $NoPropagateInherit)
            {
                $NoPropagateInherit = $false
            }

            $ReferenceRuleInfo += [PSCustomObject]@{
                AccessControlType = $AccessControlType
                FileSystemRights = $FileSystemRights
                Inheritance = $Inheritance
                NoPropagateInherit = $NoPropagateInherit
            }
        }
    }
    else
    {
        Write-Verbose -Message 'The AccessControlInformation property is not specified.'

        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message 'The default permission entry will be used as the reference permission entry.'

            $ReferenceRuleInfo += [PSCustomObject]@{
                AccessControlType = 'Allow'
                FileSystemRights = 'ReadAndExecute'
                Inheritance = $null
                NoPropagateInherit = $false
            }
        }
    }

    if ($Ensure -eq 'Absent' -and $AccessRules.Count -ne 0)
    {
        if ($ReferenceRuleInfo.Count -ne 0)
        {
            $ReferenceRuleInfo |
            ForEach-Object -Begin {$Counter = 0} -Process {

                $Entry = $_

                $ReferenceRule = New-FileSystemAccessRule `
                    -ItemType $ItemType `
                    -Principal $Identity.Name `
                    -AccessControlType $Entry.AccessControlType `
                    -FileSystemRights $Entry.FileSystemRights `
                    -Inheritance $Entry.Inheritance `
                    -NoPropagateInherit $Entry.NoPropagateInherit `
                    -ErrorAction Stop

                $MatchingRule = $AccessRules |
                    Where-Object -FilterScript {
                        ($_.AccessControlType -eq $ReferenceRule.AccessControlType) -and
                        ($_.FileSystemRights -eq $ReferenceRule.FileSystemRights) -and
                        ($_.InheritanceFlags -eq $ReferenceRule.InheritanceFlags) -and
                        ($_.PropagationFlags -eq $ReferenceRule.PropagationFlags)
                    }

                if ($MatchingRule)
                {
                    ("Permission entry was found ({0} of {1}) :" -f (++$Counter), $ReferenceRuleInfo.Count),
                    ("> IdentityReference : '{0}'" -f $MatchingRule.IdentityReference),
                    ("> AccessControlType : '{0}'" -f $MatchingRule.AccessControlType),
                    ("> FileSystemRights  : '{0}'" -f $MatchingRule.FileSystemRights),
                    ("> InheritanceFlags  : '{0}'" -f $MatchingRule.InheritanceFlags),
                    ("> PropagationFlags  : '{0}'" -f $MatchingRule.PropagationFlags) |
                    Write-Verbose

                    $InDesiredState = $false
                }
                else
                {
                    ("Permission entry was not found ({0} of {1}) :" -f (++$Counter), $ReferenceRuleInfo.Count),
                    ("> IdentityReference : '{0}'" -f $ReferenceRule.IdentityReference),
                    ("> AccessControlType : '{0}'" -f $ReferenceRule.AccessControlType),
                    ("> FileSystemRights  : '{0}'" -f $ReferenceRule.FileSystemRights),
                    ("> InheritanceFlags  : '{0}'" -f $ReferenceRule.InheritanceFlags),
                    ("> PropagationFlags  : '{0}'" -f $ReferenceRule.PropagationFlags) |
                    Write-Verbose
                }

            }
        }
        else
        {
            # All explicit permissions associated with the specified principal should be removed.
            $InDesiredState = $false
        }
    }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message "Desired permission entry count : $($ReferenceRuleInfo.Count)"

        if ($AccessRules.Count -ne $ReferenceRuleInfo.Count)
        {
            Write-Verbose -Message 'The number of current permission entries is different from the number of desired permission entries.'

            $InDesiredState = $false
        }

        $ReferenceRuleInfo |
        ForEach-Object -Begin {$Counter = 0} -Process {

            $Entry = $_

            $ReferenceRule = New-FileSystemAccessRule `
                -ItemType $ItemType `
                -Principal $Identity.Name `
                -AccessControlType $Entry.AccessControlType `
                -FileSystemRights $Entry.FileSystemRights `
                -Inheritance $Entry.Inheritance `
                -NoPropagateInherit $Entry.NoPropagateInherit `
                -ErrorAction Stop

            $MatchingRule = $AccessRules |
                Where-Object -FilterScript {
                    ($_.AccessControlType -eq $ReferenceRule.AccessControlType) -and
                    ($_.FileSystemRights -eq $ReferenceRule.FileSystemRights) -and
                    ($_.InheritanceFlags -eq $ReferenceRule.InheritanceFlags) -and
                    ($_.PropagationFlags -eq $ReferenceRule.PropagationFlags)
                }

            if ($MatchingRule)
            {
                ("Permission entry was found ({0} of {1}) :" -f (++$Counter), $ReferenceRuleInfo.Count),
                ("> IdentityReference : '{0}'" -f $MatchingRule.IdentityReference),
                ("> AccessControlType : '{0}'" -f $MatchingRule.AccessControlType),
                ("> FileSystemRights  : '{0}'" -f $MatchingRule.FileSystemRights),
                ("> InheritanceFlags  : '{0}'" -f $MatchingRule.InheritanceFlags),
                ("> PropagationFlags  : '{0}'" -f $MatchingRule.PropagationFlags) |
                Write-Verbose
            }
            else
            {
                ("Permission entry was not found ({0} of {1}) :" -f (++$Counter), $ReferenceRuleInfo.Count),
                ("> IdentityReference : '{0}'" -f $ReferenceRule.IdentityReference),
                ("> AccessControlType : '{0}'" -f $ReferenceRule.AccessControlType),
                ("> FileSystemRights  : '{0}'" -f $ReferenceRule.FileSystemRights),
                ("> InheritanceFlags  : '{0}'" -f $ReferenceRule.InheritanceFlags),
                ("> PropagationFlags  : '{0}'" -f $ReferenceRule.PropagationFlags) |
                Write-Verbose

                $InDesiredState = $false
            }

        }
    }

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
        [Parameter(Mandatory = $false)]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [String]
        $Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Directory', 'File')]
        [String]
        $ItemType,

        [Parameter(Mandatory = $true)]
        [String]
        $Principal,

        [Parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlInformation
    )

    $Acl = Get-Acl -Path $Path -ErrorAction Stop

    if ($Acl -is [System.Security.AccessControl.DirectorySecurity])
    {
        $ItemType = 'Directory'
    }
    else
    {
        $ItemType = 'File'
    }

    $Identity = Resolve-IdentityReference -Identity $Principal -ErrorAction Stop

    [System.Security.AccessControl.FileSystemAccessRule[]]$AccessRules = @(
        $Acl.Access |
        Where-Object -FilterScript {
            ($_.IsInherited -eq $false) -and
            ($_.IdentityReference -eq $Identity.Name)
        }
    )

    Write-Verbose -Message "Current permission entry count : $($AccessRules.Count)"

    [PSCustomObject[]]$ReferenceRuleInfo = @()

    if ($PSBoundParameters.ContainsKey('AccessControlInformation'))
    {
        foreach ($Instance in $AccessControlInformation)
        {
            $AccessControlType = $Instance.CimInstanceProperties.Where({$_.Name -eq 'AccessControlType'}).ForEach({$_.Value})
            $FileSystemRights = $Instance.CimInstanceProperties.Where({$_.Name -eq 'FileSystemRights'}).ForEach({$_.Value})
            $Inheritance = $Instance.CimInstanceProperties.Where({$_.Name -eq 'Inheritance'}).ForEach({$_.Value})
            $NoPropagateInherit = $Instance.CimInstanceProperties.Where({$_.Name -eq 'NoPropagateInherit'}).ForEach({$_.Value})

            if (-not $AccessControlType)
            {
                $AccessControlType = 'Allow'
            }

            if (-not $FileSystemRights)
            {
                $FileSystemRights = 'ReadAndExecute'
            }

            if (-not $NoPropagateInherit)
            {
                $NoPropagateInherit = $false
            }

            $ReferenceRuleInfo += [PSCustomObject]@{
                AccessControlType = $AccessControlType
                FileSystemRights = $FileSystemRights
                Inheritance = $Inheritance
                NoPropagateInherit = $NoPropagateInherit
            }
        }
    }
    else
    {
        Write-Verbose -Message 'The AccessControlInformation property is not specified.'

        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message 'The default permission entry will be added.'

            $ReferenceRuleInfo += [PSCustomObject]@{
                AccessControlType = 'Allow'
                FileSystemRights = 'ReadAndExecute'
                Inheritance = $null
                NoPropagateInherit = $false
            }
        }
    }

    if ($Ensure -eq 'Absent' -and $AccessRules.Count -ne 0)
    {
        if ($ReferenceRuleInfo.Count -ne 0)
        {
            $ReferenceRuleInfo |
            ForEach-Object -Begin {$Counter = 0} -Process {

                $Entry = $_

                $ReferenceRule = New-FileSystemAccessRule `
                    -ItemType $ItemType `
                    -Principal $Identity.Name `
                    -AccessControlType $Entry.AccessControlType `
                    -FileSystemRights $Entry.FileSystemRights `
                    -Inheritance $Entry.Inheritance `
                    -NoPropagateInherit $Entry.NoPropagateInherit `
                    -ErrorAction Stop

                $MatchingRule = $AccessRules |
                    Where-Object -FilterScript {
                        ($_.AccessControlType -eq $ReferenceRule.AccessControlType) -and
                        ($_.FileSystemRights -eq $ReferenceRule.FileSystemRights) -and
                        ($_.InheritanceFlags -eq $ReferenceRule.InheritanceFlags) -and
                        ($_.PropagationFlags -eq $ReferenceRule.PropagationFlags)
                    }

                if ($MatchingRule)
                {
                    ("Removing permission entry ({0} of {1}) :" -f (++$Counter), $ReferenceRuleInfo.Count),
                    ("> IdentityReference : '{0}'" -f $MatchingRule.IdentityReference),
                    ("> AccessControlType : '{0}'" -f $MatchingRule.AccessControlType),
                    ("> FileSystemRights  : '{0}'" -f $MatchingRule.FileSystemRights),
                    ("> InheritanceFlags  : '{0}'" -f $MatchingRule.InheritanceFlags),
                    ("> PropagationFlags  : '{0}'" -f $MatchingRule.PropagationFlags) |
                    Write-Verbose

                    $Modified = $null
                    $Acl.ModifyAccessRule('RemoveSpecific', $MatchingRule, [Ref]$Modified)
                }
            }
        }
        else
        {
            "Removing all explicit permissions for principal '{0}'." -f $($AccessRules[0].IdentityReference) |
            Write-Verbose

            $Modified = $null
            $Acl.ModifyAccessRule('RemoveAll', $AccessRules[0], [Ref]$Modified)
        }
    }

    if ($Ensure -eq 'Present')
    {
        if ($AccessRules.Count -ne 0)
        {
            "Removing all explicit permissions for principal '{0}'." -f $($AccessRules[0].IdentityReference) |
            Write-Verbose

            $Modified = $null
            $Acl.ModifyAccessRule('RemoveAll', $AccessRules[0], [Ref]$Modified)
        }

        $ReferenceRuleInfo |
        ForEach-Object -Begin {$Counter = 0} -Process {

            $Entry = $_

            $ReferenceRule = New-FileSystemAccessRule `
                -ItemType $ItemType `
                -Principal $Identity.Name `
                -AccessControlType $Entry.AccessControlType `
                -FileSystemRights $Entry.FileSystemRights `
                -Inheritance $Entry.Inheritance `
                -NoPropagateInherit $Entry.NoPropagateInherit `
                -ErrorAction Stop

            ("Adding permission entry ({0} of {1}) :" -f (++$Counter), $ReferenceRuleInfo.Count),
            ("> IdentityReference : '{0}'" -f $ReferenceRule.IdentityReference),
            ("> AccessControlType : '{0}'" -f $ReferenceRule.AccessControlType),
            ("> FileSystemRights  : '{0}'" -f $ReferenceRule.FileSystemRights),
            ("> InheritanceFlags  : '{0}'" -f $ReferenceRule.InheritanceFlags),
            ("> PropagationFlags  : '{0}'" -f $ReferenceRule.PropagationFlags) |
            Write-Verbose

            $Acl.AddAccessRule($ReferenceRule)

        }
    }

    Set-FileSystemAccessControl -Path $Path -Acl $Acl
}

#region Helper Functions

function ConvertFrom-FileSystemAccessRule
{
    <#
    .SYNOPSIS
        Converts a FileSystemAccessRule object to a custom object.

    .DESCRIPTION
        The ConvertFrom-FileSystemAccessRule function converts a FileSystemAccessRule object to a custom object.

    .PARAMETER ItemType
        Specifies whether the item is a directory or a file.

    .PARAMETER InputObject
        Specifies the FileSystemAccessRule object to convert.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Directory', 'File')]
        [String]
        $ItemType,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Security.AccessControl.FileSystemAccessRule]
        $InputObject
    )
    process
    {
        [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = $InputObject.InheritanceFlags
        [System.Security.AccessControl.PropagationFlags]$PropagationFlags = $InputObject.PropagationFlags

        $NoPropagateInherit = $PropagationFlags.HasFlag([System.Security.AccessControl.PropagationFlags]::NoPropagateInherit)

        if ($NoPropagateInherit)
        {
            [System.Security.AccessControl.PropagationFlags]$PropagationFlags =
                $PropagationFlags -bxor [System.Security.AccessControl.PropagationFlags]::NoPropagateInherit
        }

        if ($InheritanceFlags -eq 'None' -and $PropagationFlags -eq 'None')
        {
            if ($ItemType -eq 'Directory')
            {
                $Inheritance = 'ThisFolderOnly'
            }
            else
            {
                $Inheritance = 'None'
            }
        }
        elseif ($InheritanceFlags -eq 'ContainerInherit, ObjectInherit' -and $PropagationFlags -eq 'None')
        {
            $Inheritance = 'ThisFolderSubfoldersAndFiles'
        }
        elseif ($InheritanceFlags -eq 'ContainerInherit' -and $PropagationFlags -eq 'None')
        {
            $Inheritance = 'ThisFolderAndSubfolders'
        }
        elseif ($InheritanceFlags -eq 'ObjectInherit' -and $PropagationFlags -eq 'None')
        {
            $Inheritance = 'ThisFolderAndFiles'
        }
        elseif ($InheritanceFlags -eq 'ContainerInherit, ObjectInherit' -and $PropagationFlags -eq 'InheritOnly')
        {
            $Inheritance = 'SubfoldersAndFilesOnly'
        }
        elseif ($InheritanceFlags -eq 'ContainerInherit' -and $PropagationFlags -eq 'InheritOnly')
        {
            $Inheritance = 'SubfoldersOnly'
        }
        elseif ($InheritanceFlags -eq 'ObjectInherit' -and $PropagationFlags -eq 'InheritOnly')
        {
            $Inheritance = 'FilesOnly'
        }

        $OutputObject = [PSCustomObject]@{
            ItemType = $ItemType
            Principal = [String]$InputObject.IdentityReference
            AccessControlType = [String]$InputObject.AccessControlType
            FileSystemRights = [String]$InputObject.FileSystemRights
            Inheritance = $Inheritance
            NoPropagateInherit = $NoPropagateInherit
        }

        return $OutputObject
    }
}

function New-FileSystemAccessRule
{
    <#
    .SYNOPSIS
        Creates a FileSystemAccessRule object.

    .DESCRIPTION
        The New-FileSystemAccessRule function creates a FileSystemAccessRule object
        that represents an abstraction of an access control entry (ACE).

    .PARAMETER ItemType
        Specifies whether the item is a directory or a file.

    .PARAMETER Principal
        Specifies the identity of the principal.

    .PARAMETER AccessControlType
        Specifies whether the ACE to be used to allow or deny access.

    .PARAMETER FileSystemRights
        Specifies the access rights to be granted to the principal.

    .PARAMETER Inheritance
        Specifies the inheritance type of the ACE.

    .PARAMETER NoPropagateInherit
        Specifies that the ACE is not propagated to child objects.
    #>
    [CmdletBinding()]
    [OutputType([System.Security.AccessControl.FileSystemAccessRule])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Directory', 'File')]
        [String]
        $ItemType,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $Principal,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Allow', 'Deny')]
        [String]
        $AccessControlType,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.Security.AccessControl.FileSystemRights]
        $FileSystemRights,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet(
            $null,
            'None',
            'ThisFolderOnly',
            'ThisFolderSubfoldersAndFiles',
            'ThisFolderAndSubfolders',
            'ThisFolderAndFiles',
            'SubfoldersAndFilesOnly',
            'SubfoldersOnly',
            'FilesOnly'
        )]
        [String]
        $Inheritance = 'ThisFolderSubfoldersAndFiles',

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Boolean]
        $NoPropagateInherit = $false
    )
    process
    {
        if ($ItemType -eq 'Directory')
        {
            switch ($Inheritance)
            {
                {$_ -in @('None', 'ThisFolderOnly')}
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'None'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'None'
                }

                'ThisFolderSubfoldersAndFiles'
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ContainerInherit', 'ObjectInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'None'
                }

                'ThisFolderAndSubfolders'
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ContainerInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'None'
                }

                'ThisFolderAndFiles'
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ObjectInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'None'
                }

                'SubfoldersAndFilesOnly'
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ContainerInherit', 'ObjectInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'InheritOnly'
                }

                'SubfoldersOnly'
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ContainerInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'InheritOnly'
                }

                'FilesOnly'
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ObjectInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'InheritOnly'
                }

                default
                {
                    [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'ContainerInherit', 'ObjectInherit'
                    [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'None'
                }
            }

            if ($NoPropagateInherit -eq $true -and $InheritanceFlags -ne 'None')
            {
                [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'NoPropagateInherit'
            }
        }
        else
        {
            [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = 'None'
            [System.Security.AccessControl.PropagationFlags]$PropagationFlags = 'None'
        }

        $OutputObject = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule `
            -ArgumentList $Principal, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType

        return $OutputObject
    }
}

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

function Resolve-IdentityReference
{
    <#
    .SYNOPSIS
        Resolves the identity of the principal.

    .DESCRIPTION
        The Resolve-IdentityReference function resolves the identity of the principal
        and returns its down-level logon name and security identifier (SID).

    .PARAMETER Identity
        Specifies the identity of the principal.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Identity
    )
    process
    {
        try
        {
            Write-Verbose -Message "Resolving identity reference '$Identity'."

            if ($Identity -match '^S-\d-(\d+-){1,14}\d+$')
            {
                [System.Security.Principal.SecurityIdentifier]$Identity = $Identity
            }
            else
            {
                [System.Security.Principal.NTAccount]$Identity = $Identity
            }

            $SID = $Identity.Translate([System.Security.Principal.SecurityIdentifier])
            $NTAccount = $SID.Translate([System.Security.Principal.NTAccount])

            $OutputObject = [PSCustomObject]@{
                Name = $NTAccount.Value
                SID = $SID.Value
            }

            return $OutputObject
        }
        catch
        {
            $ErrorMessage = "Could not resolve identity reference '{0}': '{1}'." -f $Identity, $_.Exception.Message
            Write-Error -Exception $_.Exception -Message $ErrorMessage
            return
        }
    }
}

#endregion
