<#
.SYNOPSIS
    Disable NTFS permissions inheritance.
.DESCRIPTION
    This example shows how to use the cNtfsPermissionsInheritance DSC resource to disable NTFS permissions inheritance.
#>

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
    Import-DscResource -ModuleName PSDesiredStateConfiguration

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
