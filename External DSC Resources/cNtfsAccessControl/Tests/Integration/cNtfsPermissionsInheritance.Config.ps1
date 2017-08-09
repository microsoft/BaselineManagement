#requires -Version 4.0

$TestParameters = [PSCustomObject]@{
    Path = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid().Guid))
    Enabled = $false
    PreserveInherited = $true
}

Configuration cNtfsPermissionsInheritance_Config
{
    Import-DscResource -ModuleName cNtfsAccessControl

    Node localhost
    {
        cNtfsPermissionsInheritance Test
        {
            Path = $TestParameters.Path
            Enabled = $TestParameters.Enabled
            PreserveInherited = $TestParameters.PreserveInherited
        }
    }
}
