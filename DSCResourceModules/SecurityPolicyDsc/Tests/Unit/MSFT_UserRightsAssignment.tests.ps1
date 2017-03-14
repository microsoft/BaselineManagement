
$script:dscModuleName    = 'SecurityPolicyDsc' 
$script:dscResourceName  = 'MSFT_UserRightsAssignment'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {

            $testParameters = [PSObject]@{
                Policy   = 'Access_Credential_Manager_as_a_trusted_caller'                
                Identity = 'contoso\TestUser1'                
            }

            $mockGetUSRPolicyResult = [PSObject]@{
                Policy = 'SeTrustedCredManAccessPrivilege'
                Identity = 'contoso\testUser1','contoso\TestUser2'
                PolicyFriendlyName = $testParameters.Policy
            }

            $mockUSRDoesNotExist = [PSObject]@{
                Policy = 'SeTrustedCredManAccessPrivilege'
                Identity = 'contoso\testUser3','contoso\TestUser2'
                PolicyFriendlyName = $testParameters.Policy
            }

            $mockNullIdentity = [PSObject] @{
                Policy = 'Access_Credential_Manager_as_a_trusted_caller'
                Identity = $null
            }

            $mockGetTargetResult = [PSObject] @{
                Policy = 'Access_Credential_Manager_as_a_trusted_caller'
                Identity = 'contoso\TestUser2'
            }
        #endregion

        #region Function Get-TargetResource
        Describe "Get-TargetResource" {  
            Context 'Identity should match on Policy' {
                Mock -CommandName Get-USRPolicy -MockWith {return @($testParameters)}
                Mock -CommandName Test-TargetResource -MockWith {$false}

                It 'Should not match Identity' {                    
                    $result = Get-TargetResource @testParameters

                    $result.Identity | Should Be $testParameters.Identity
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-USRPolicy -Exactly 1
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "Test-TargetResource" {
            Context 'Identity does exist and should' {
                Mock -CommandName  Get-USRPolicy -MockWith {$mockGetUSRPolicyResult}

                It 'Should return true' {
                    $testResult = Test-TargetResource @testParameters

                    $testResult | Should Be $true
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled -CommandName Get-USRPolicy -Exactly 1
                }
            }

            Context 'Identity does not exist' {
                Mock -CommandName Get-USRPolicy -MockWith {$mockUSRDoesNotExist}

                It 'Shoud return false' {
                   $testResult = Test-TargetResource @testParameters
                   $testResult | Should be $false
                }
            }

            Context 'Identity does not exist but should' {
                Mock -CommandName Get-USRPolicy -MockWith {}

                It 'Should return false' {
                    $testResult = Test-TargetResource @testParameters

                    $testResult | Should Be $false
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled -CommandName Get-USRPolicy -Exactly 1
                } 
            }

            Context 'Identity is NULL and should be' {
                It 'Should return true' {
                    Mock -CommandName Get-USRPolicy -MockWith {$mockNullIdentity}
                    $testResult = Test-TargetResource -Policy Access_Credential_Manager_as_a_trusted_caller -Identity ""

                    $testResult | Should be $true
                }

                It 'Should return false' {
                    Mock -CommandName Get-USRPolicy -MockWith {$mockGetUSRPolicyResult}
                    $testResult = Test-TargetResource -Policy Access_Credential_Manager_as_a_trusted_caller -Identity ""

                    $testResult | Should be $false
                }
            }
        }
        #endregion
        #region Function Set-TargetResource
        Describe "Set-TargetResource" {
            Context 'Identity does not exist but should' {
                Mock -CommandName Invoke-Secedit -MockWith {}
                Mock -CommandName Test-TargetResource -MockWith {$true}
                Mock -CommandName Get-Content -ParameterFilter {$Path -match "Secedit-OutPut.txt"} -MockWith {"Tasked Failed"}             

                It 'Should not throw' { 
                    {Set-TargetResource @testParameters} | Should Not Throw
                }

                It 'Should throw when set fails' {
                    Mock Test-TargetResource -MockWith {$false}  
                    {Set-TargetResource @testParameters} | Should Throw $script:localizedData.TaskFail
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled -CommandName Invoke-Secedit -Exactly 2
                    Assert-MockCalled -CommandName Test-TargetResource -Exactly 2
                }
            }

            Context 'Identity is NULL' {
                It 'Should not throw' {
                    Mock -CommandName Invoke-Secedit -MockWith {}
                    Mock -CommandName Test-TargetResource -MockWith {$true}            
                    $setParameters = @{
                        Policy = 'Access_Credential_Manager_as_a_trusted_caller'
                        Identity = ""
                    }               
                    {Set-TargetResource @setParameters} | Should Not Throw
                }

                It 'Should call expected mocks' {
                    Assert-MockCalled -CommandName Invoke-Secedit
                    Assert-MockCalled -CommandName Test-TargetResource                    
                }
            }
        }
        #endregion
        #region Function Get-USRPolicy
        Describe "Get-USRPolicy" {
            Mock -CommandName Get-AssignmentFriendlyNames -MockWith { @{'Access_Credential_Manager_as_a_trusted_caller' = 'SeTrustedCredManAccessPrivilege'}}
            Mock -CommandName Get-UserRightsAssignment -MockWith {@{'Privilege Rights' = @{'SeTrustedCredManAccessPrivilege' = "foo"}}}

            $getUsrResult = Get-USRPolicy -Policy 'Access_Credential_Manager_as_a_trusted_caller' -Areas USER_Rights

            It 'Should match policy' {
                $getUsrResult.Policy | Should Be 'SeTrustedCredManAccessPrivilege'
            }
            It 'Should match PolicyFriendlyName' {
                $getUsrResult.PolicyFriendlyName | Should be 'Access_Credential_Manager_as_a_trusted_caller'
            }
            It 'Should match Identity' {
                $getUsrResult.Identity | Should be 'foo'
            }

            It 'Should call expected mnocks' {
                Assert-MockCalled -CommandName Get-AssignmentFriendlyNames
                Assert-MockCalled -CommandName Get-UserRightsAssignment
            }
        }
        #endregion    
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
