
$script:DSCModuleName      = 'SecurityPolicyDsc'
$script:DSCResourceName    = 'MSFT_UserRightsAssignment'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration 
#endregion


try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {

        #region DEFAULT TESTS
        Context "Default Tests" {
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -OutputPath $TestDrive
                    Start-DscConfiguration -Path $TestDrive `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }
        }
        #endregion

        Context 'Verify Successful Configuration on Trusted Caller' {
            Import-Module "$PSScriptRoot\..\..\DSCResources\MSFT_UserRightsAssignment\MSFT_UserRightsAssignment.psm1"
            It 'Should have set the resource and all the parameters should match' {
                $getResults = Get-TargetResource -Policy $rule.Policy -Identity $rule.Identity
                 
                foreach ($Id in $rule.Identity)
                {
                    $getResults.Identity | where {$_ -eq $Id} | Should Be $Id
                }

                $rule.Policy | Should Be $getResults.Policy
            }
        }

        Context 'Verify Success on Act as OS remove all' {

            It 'Should have set the resource and all the parameters should match' {
                $getResults = Get-TargetResource -Policy $removeAll.Policy -Identity $removeAll.Identity
                 
                foreach ($Id in $removeAll.Identity)
                {
                    $getResults.Identity | where {$_ -eq $Id} | Should Be $null
                }

                $removeAll.Policy | Should Be $getResults.Policy
            }
        }
    }
    #endregion
}

finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
    #endregion

}
