$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;

## Dot source all (nested) .ps1 files in the folder, excluding Pester tests
Get-ChildItem -Path $moduleRoot -Include *.ps1 -Exclude '*.Tests.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose ('Dot sourcing ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }

Export-ModuleMember -Function *-TargetResource;
