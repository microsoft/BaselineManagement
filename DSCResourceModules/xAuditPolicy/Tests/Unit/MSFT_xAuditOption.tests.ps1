<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename MSFT_x<ResourceName>.tests.ps1
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>

$Global:DSCModuleName      = 'xAuditPolicy'
$Global:DSCResourceName    = 'MSFT_xAuditOption'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# set the audit option test strings to Mock
$optionName  = 'CrashOnAuditFail'
$optionState = 'Disabled'
$optionStateSwap = @{'Disabled'='Enabled';'Enabled'='Disabled'}

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        # TODO: Optopnal Load Mock for use in Pester tests here...
        #endregion


        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            # mock call to the helper module to isolate Get-TargetResource
            Mock Get-AuditOption { return $optionState } -ModuleName MSFT_xAuditOption

            $get = Get-TargetResource -Name $optionName

            Assert-MockCalled Get-AuditOption -Exactly 1 -Scope Describe

            It "Return object is a hashtable" {
                $isHashtable = $get.GetType().Name -eq 'hashtable'
                
                $isHashtable | Should Be $true
            }

            It " that has a 'Name' key" {
                $containsNameKey = $get.ContainsKey('Name')

                $containsNameKey | Should Be $true
            }
            
            It "  with a value of '$optionName'" {
                $retrievedOptionName = $get.Name 
                $retrievedOptionName | Should Be $optionName
            }

            It " that has a 'Value' key" {
                $containsValueKey = $get.ContainsKey('Value')
                $containsValueKey | Should Be $true
            }
            
            It "  with a value of '$optionState'" {
                $get.Value | Should Be $optionState
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            
            # mock call to the helper module to isolate Test-TargetResource
            Mock Get-AuditOption { return $optionState } -ModuleName MSFT_xAuditOption

            $test = Test-TargetResource -Name $optionName -Value $optionState

            It "Return object is a Boolean" {
                $isBool = $test.GetType().Name -eq "Boolean"

                $isBool | Should Be $true
            }

            It " that is true when matching" {
                $valueMatches = $test
                
                $valueMatches | Should Be $true
            }

            It " and is false when not matching" {
                $valueNotMatches = Test-TargetResource -Name $optionName -Value $optionStateSwap[$optionState]
                
                $valueNotMatches | Should Be $false

                Assert-MockCalled Get-AuditOption -Exactly 1 -Scope It
            }

            
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            # mock call to the helper module to isolate Set-TargetResource
            Mock Set-AuditOption { return } -ModuleName MSFT_xAuditOption
                
            $set = Set-TargetResource -Name $optionName -Value $optionState

            It " returns no object" {
                
                $set | Should BeNullOrEmpty
            } 

            Assert-MockCalled Set-AuditOption 1
        }
        #endregion

        # TODO: Pester Tests for any Helper Cmdlets

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
