#Requires -Modules psake

<#
 .Synopsis
 This script copies the build and test files to local projects
 before executing the Psake build script. 
#>
[cmdletbinding()]
Param
(
    <# 
        This defines the root directory of the project being built.
        This is set by the VS Code varaible ${workspaceRoot} in the
        task configuration. The default value is only available in 
        the TFS build system.
    #>
    [Parameter()]
    [ValidateSet('Analyze','Build','Clean','Test.Integration','Test.Unit','Deploy','Publish')]
    [String]
    $Task="Publish"
)

Invoke-psake -buildFile $PSScriptRoot\psake.tasks.ps1 -taskList $task

# This final test is required for the TFS PowerShell task to fail. If this is not in place, 
# the psake script can fail, but this calling script completes successfully so the build
# continues on a failed task.
if (-not $psake.build_success )
{
    Throw "See PSake error logs"
}
