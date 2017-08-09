#requires -Version 4.0 -Modules Pester

$Global:DSCModuleName   = 'cNtfsAccessControl'
$Global:DSCResourceName = 'cNtfsPermissionsInheritance'

#region Header

$ModuleRoot = Split-Path -Path $Script:MyInvocation.MyCommand.Path -Parent | Split-Path -Parent | Split-Path -Parent

if (
    (-not (Test-Path -Path (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests') -PathType Container)) -or
    (-not (Test-Path -Path (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -PathType Leaf))
)
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Integration

#endregion

try
{
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).Config.ps1"
    . $ConfigFile

    #region Create temporary directory

    $TestDirectory = New-Item -Path $TestParameters.Path -ItemType Directory -Force -Verbose
    $Acl = $TestDirectory.GetAccessControl()
    $Acl.SetAccessRuleProtection($false, $false)
    $Acl.Access.Where({-not $_.IsInherited}).ForEach({[Void]$Acl.RemoveAccessRule($_)})
    [System.IO.Directory]::SetAccessControl($TestDirectory.FullName, $Acl)

    #endregion

    #region Integration Tests

    Describe "$($Global:DSCResourceName)_Integration" {

        #region Default Tests

        $ConfigurationName = "$($Global:DSCResourceName)_Config"

        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command ('{0} -OutputPath "{1}"' -f $ConfigurationName, $TestEnvironment.WorkingFolder)
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Force -Verbose -Wait
            } | Should Not Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should Not Throw
        }

        #endregion

        It 'Should have set the resource and all the parameters should match' {

            $CurrentConfiguration = Get-DscConfiguration |
                Where-Object -FilterScript {$_.ConfigurationName -eq $ConfigurationName}

            $CurrentConfiguration.Path              | Should Be $TestParameters.Path
            $CurrentConfiguration.Enabled           | Should Be $TestParameters.Enabled
            $CurrentConfiguration.PreserveInherited | Should Be $TestParameters.PreserveInherited

        }

        It 'Actual configuration should match the desired configuration' {
            Test-DscConfiguration -Verbose | Should Be $true
        }

    }

    #endregion
}
finally
{
    #region Footer

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion

    # Remove temporary directory
    if ($TestDirectory)
    {
        Remove-Item -Path $TestDirectory.FullName -Force -Recurse -Verbose
    }
}
