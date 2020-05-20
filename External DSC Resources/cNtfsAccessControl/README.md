[![Build status](https://ci.appveyor.com/api/projects/status/olfva3iu8lcehhf1?svg=true)](https://ci.appveyor.com/project/SNikalaichyk/cNtfsAccessControl)

# cNtfsAccessControl

The **cNtfsAccessControl** module contains DSC resources for NTFS access control management.

You can also download this module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/cNtfsAccessControl/).

## Resources

### cNtfsPermissionEntry

The **cNtfsPermissionEntry** DSC resource provides a mechanism to manage NTFS permissions.

* **Ensure**: Indicates if the principal has explicitly assigned NTFS permissions on the target path.
    Set this property to `Present` (the default value) to ensure they exactly match what is provided through the **AccessControlInformation** property.
    If the **AccessControlInformation** property is not specified, the default permission entry is used as the reference permission entry.
    If this property is set to `Absent` and the **AccessControlInformation** property is not specified, all explicit permissions associated with the specified principal are removed.
* **Path**: Indicates the path to the target item.
* **Principal**: Indicates the identity of the principal. Valid formats are:
    * [Down-Level Logon Name](https://msdn.microsoft.com/en-us/library/windows/desktop/aa380525%28v=vs.85%29.aspx#down_level_logon_name)
    * [Security Accounts Manager (SAM) Account Name (sAMAccountName)](https://msdn.microsoft.com/en-us/library/windows/desktop/ms679635%28v=vs.85%29.aspx)
    * [Security Identifier (SID)](https://msdn.microsoft.com/en-us/library/cc246018.aspx)
    * [User Principal Name (UPN)](https://msdn.microsoft.com/en-us/library/windows/desktop/aa380525%28v=vs.85%29.aspx#user_principal_name)
* **AccessControlInformation**: Indicates the access control information in the form of an array of instances of the **cNtfsAccessControlInformation** CIM class. Its properties are as follows:
    * **AccessControlType**: Indicates whether to `Allow` or `Deny` access to the target item. The default value is `Allow`.
    * **FileSystemRights**: Indicates the access rights to be granted to the principal.
        Specify one or more values from the [System.Security.AccessControl.FileSystemRights](https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights%28v=vs.110%29.aspx) enumeration type.
        Multiple values can be specified by using an array of strings or a single comma-separated string. The default value is `ReadAndExecute`.
    * **Inheritance**: Indicates the inheritance type of the permission entry. This property is only applicable to directories. Valid values are:
        * `None`
        * `ThisFolderOnly`
        * `ThisFolderSubfoldersAndFiles` (the default value)
        * `ThisFolderAndSubfolders`
        * `ThisFolderAndFiles`
        * `SubfoldersAndFilesOnly`
        * `SubfoldersOnly`
        * `FilesOnly`
    * **NoPropagateInherit**: Indicates whether the permission entry is not propagated to child objects. This property is only applicable to directories.
        Set this property to `$true` to ensure inheritance is limited only to those sub-objects that are immediately subordinate to the target item. The default value is `$false`.

### cNtfsPermissionsInheritance

The **cNtfsPermissionsInheritance** DSC resource provides a mechanism to manage NTFS permissions inheritance.

* **Path**: Indicates the path to the target item.
* **Enabled**: Indicates whether NTFS permissions inheritance is enabled. Set this property to `$false` to ensure it is disabled. The default value is `$true`.
* **PreserveInherited**: Indicates whether to preserve inherited permissions. Set this property to `$true` to convert inherited permissions into explicit permissions.
    The default value is `$false`. **Note:** This property is only valid when the **Enabled** property is set to `$false`.

## Versions

### 1.3.0 (May 04, 2016)

* Changed the behavior of the **cNtfsPermissionEntry** DSC resource with the **Ensure** property set to `Absent`. Added an ability to remove specific permission entries.
* General improvements.

### 1.2.0 (February 19, 2016)

* The **ItemType** property of the **cNtfsPermissionEntry** DSC resource was deprecated.
* The **cNtfsPermissionsInheritance** DSC resource was added.
* Unit and integration tests were added.
* Bug fixes and general improvements.

### 1.1.1 (October 15, 2015)

* Minor update.

### 1.1.0 (September 30, 2015)

* The **PermissionEntry** property was renamed to **AccessControlInformation**.

### 1.0.0 (September 29, 2015)

* Initial release with the following DSC resources:
    * **cNtfsPermissionEntry**

## Examples

### Assign NTFS permissions

This example shows how to use the **cNtfsPermissionEntry** DSC resource to assign NTFS permissions.

```powershell

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

```

### Disable NTFS permissions inheritance

This example shows how to use the **cNtfsPermissionsInheritance** DSC resource to disable NTFS permissions inheritance.

```powershell

Configuration Sample_cNtfsPermissionsInheritance
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

    # Disable NTFS permissions inheritance.
    cNtfsPermissionsInheritance DisableInheritance
    {
        Path = $Path
        Enabled = $false
        PreserveInherited = $true
        DependsOn = '[File]TestDirectory'
    }
}

$OutputPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'Sample_cNtfsPermissionsInheritance'
Sample_cNtfsPermissionsInheritance -OutputPath $OutputPath
Start-DscConfiguration -Path $OutputPath -Force -Verbose -Wait

```
