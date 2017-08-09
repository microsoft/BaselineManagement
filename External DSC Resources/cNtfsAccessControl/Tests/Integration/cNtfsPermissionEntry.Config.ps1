#requires -Version 4.0

$TestParameters = [PSCustomObject]@{
    Ensure = 'Present'
    Path = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid().Guid))
    Principal = 'BUILTIN\Users'
}

Configuration cNtfsPermissionEntry_Config
{
    Import-DscResource -ModuleName cNtfsAccessControl

    Node localhost
    {
        cNtfsPermissionEntry Test
        {
            Ensure = $TestParameters.Ensure
            Path = $TestParameters.Path
            Principal = $TestParameters.Principal
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
        }
    }
}
