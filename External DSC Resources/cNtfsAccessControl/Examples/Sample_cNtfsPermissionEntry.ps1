<#
.SYNOPSIS
    Assign NTFS permissions.
.DESCRIPTION
    This example shows how to use the cNtfsPermissionEntry DSC resource to assign NTFS permissions.
#>

Configuration Sample_cNtfsPermissionEntry
{
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid().Guid))
    )

    Import-DscResource -ModuleName cNtfsAccessControl
    Import-DscResource -ModuleName PSDscResoures

    File TestDirectory
    {
        Ensure = 'Present'
        DestinationPath = $Path
        Type = 'Directory'
    }

    # Ensure that a single permission entry is assigned to the local 'Users' group.
    cNtfsPermissionEntry PermissionSet1
    {
        Ensure = 'Present'
        Path = $Path
        Principal = 'BUILTIN\Users'
        AccessControlInformation = @(
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'ReadAndExecute'
                Inheritance = 'ThisFolderSubfoldersAndFiles'
                NoPropagateInherit = $false
            }
        )
        DependsOn = '[File]TestDirectory'
    }

    # Ensure that multiple permission entries are assigned to the local 'Administrators' group.
    cNtfsPermissionEntry PermissionSet2
    {
        Ensure = 'Present'
        Path = $Path
        Principal = 'BUILTIN\Administrators'
        AccessControlInformation = @(
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'Modify'
                Inheritance = 'ThisFolderOnly'
                NoPropagateInherit = $false
            }
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'ReadAndExecute'
                Inheritance = 'ThisFolderSubfoldersAndFiles'
                NoPropagateInherit = $false
            }
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'AppendData', 'CreateFiles'
                Inheritance = 'SubfoldersAndFilesOnly'
                NoPropagateInherit = $false
            }
        )
        DependsOn = '[File]TestDirectory'
    }

    # Ensure that all explicit permissions associated with the 'Authenticated Users' group are removed.
    cNtfsPermissionEntry PermissionSet3
    {
        Ensure = 'Absent'
        Path = $Path
        Principal = 'NT AUTHORITY\Authenticated Users'
        DependsOn = '[File]TestDirectory'
    }
}

$OutputPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'Sample_cNtfsPermissionEntry'
Sample_cNtfsPermissionEntry -OutputPath $OutputPath
Start-DscConfiguration -Path $OutputPath -Force -Verbose -Wait
