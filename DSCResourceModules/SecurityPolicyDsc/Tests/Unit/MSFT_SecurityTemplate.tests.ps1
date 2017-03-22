
#region HEADER

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName 'SecurityPolicyDsc' `
    -DSCResourceName 'MSFT_SecurityTemplate' `
    -TestType Unit 

#endregion HEADER

# Begin Testing
try
{ 
    InModuleScope 'MSFT_SecurityTemplate' {
        $securityModulePresent = Get-Module -Name SecurityCmdlets -ListAvailable
        $testParameters = @{
            Path = 'C:\baseline.inf'
            IsSingleInstance = 'Yes'
        }

        function Set-HashValue
        {  
            [OutputType([Hashtable])]
            param
            (
                $HashTable,
                $Key,
                $NewValue
            )

            ($HashTable.'Privilege Rights').Remove($key)
            ($HashTable.'Privilege Rights').Add($Key,$NewValue)
            $HashTable
        }

        Describe 'The system is not in a desired state' {

            $securityModulePresent = Get-Module -Name SecurityCmdlets -ListAvailable
            $mockResults = Import-Clixml -Path "$PSScriptRoot...\..\..\Misc\MockObjects\MockResults.xml"
            $modifiedMockResults = Import-Clixml -Path "$PSScriptRoot...\..\..\Misc\MockObjects\MockResults.xml"

            Context 'Get and Test method tests' {
                Mock -CommandName Get-SecurityTemplate -MockWith {}
                Mock -CommandName Test-Path -MockWith {$true}                                  

                if($securityModulePresent)
                {
                    Mock -CommandName Backup-SecurityPolicy -MockWith {}
                    Mock -CommandName Get-Module -MockWith {return $true}
                    Mock -CommandName Format-SecurityPolicyFile -MockWith {"file.inf"}

                    It 'Should return path of inf with SecurityCmdlets' { 
                        $getResult = Get-TargetResource @testParameters
                        $getResult.Path | Should BeLike "*.inf"

                        Assert-MockCalled -CommandName Format-SecurityPolicyFile -Exactly 1
                    }
                }
                else
                {
                    It 'Should return path of desired inf without SecurityCmdlets' {
                        Mock -CommandName Get-Module -MockWith {$false}
                    
                        $getResult = Get-TargetResource @testParameters
                        $getResult.Path | Should BeLike "*.inf"

                        Assert-MockCalled -CommandName Get-SecurityTemplate
                    }
                }

                It 'Should throw if inf not found' {
                    Mock -CommandName Test-Path -MockWith {$false}
                    {Test-TargetResource @testParameters} | should throw "$($testParameters.Path) not found"
                }        
                foreach($key in $mockResults.'Privilege Rights'.Keys)
                {                        
                    $mockFalseResults = Set-HashValue -HashTable $modifiedMockResults -Key $key -NewValue NoIdentity
                    
                    Mock -CommandName Get-UserRightsAssignment -MockWith {return $mockResults} -ParameterFilter {$FilePath -like "*Temp*inf*inf"}
                    Mock -CommandName Get-UserRightsAssignment -MockWith {return $mockFalseResults} -ParameterFilter {$FilePath -eq $testParameters.Path} 
                    Mock -CommandName Test-Path -MockWith {$true}

                    It "Test method should return false when testing $key" {  
                        Test-TargetResource @testParameters | Should Be $false
                    }
                }                
            }

            Context 'Set method tests' {
                if($securityModulePresent)
                {
                    Mock Restore-SecurityPolicy  -MockWith {}
                }                    
                    Mock Invoke-Secedit -MockWith {}
                    Mock Test-TargetResource -MockWith {$true}

                if($securityModulePresent)
                {        
                    It 'Should Call Restore-SecurityPolicy when SecurityCmdlet module does exist' {
                        Mock Get-Module -MockWith {$true}
                        {Set-TargetResource @testParameters} | Should Not throw
                        Assert-MockCalled -CommandName Restore-SecurityPolicy -Exactly 1                    
                    }
                }
            }
        }

        Describe 'The system is in a desired state' {
            Context 'Test for Test method' {
                $mockResults = Import-Clixml -Path "$PSScriptRoot..\..\..\Misc\MockObjects\MockResults.xml"

                It 'Should return true when in a desired state' {
                    Mock -CommandName Get-UserRightsAssignment -MockWith {$mockResults}
                    Mock -CommandName Get-SecurityTemplate -MockWith {}
                    Mock -CommandName Test-Path -MockWith {$true}
                    Mock -CommandName Get-UserRightsAssignment -MockWith {}
                    Mock -CommandName Get-Module -MockWith {}
                    
                    if($securityModulePresent)
                    {
                        Mock -CommandName Backup-SecurityPolicy -MockWith {}
                    }

                    Test-TargetResource @testParameters | should be $true                       
                }
            }
        }
        
        Describe 'Test helper functions' {
            Context 'Test Format-SecurityPolicyFile' {
                It 'Should not throw' {
                    Mock Get-Content -MockWith {@('Line1','Line2')}
                    Mock Out-File -MockWith {}
                    Mock Select-String -MockWith {}

                    {Format-SecurityPolicyFile -Path 'policy.inf'} | Should Not throw
                }
            }
            Context 'Test Invoke-Secedit' {
                Mock Start-Process -MockWith {} -ModuleName SecurityPolicyResourceHelper
                $invokeSeceditParameters = @{
                    UserRightsToAddInf = 'temp.inf'
                    SeceditOutput      = 'output.txt'
                    OverWrite          = $true
                }

                It 'Should not throw' {
                    {Invoke-Secedit @invokeSeceditParameters} | Should not throw
                }

                It 'Should call Start-Process' {
                    Assert-MockCalled -CommandName Start-Process -Exactly 1 -Scope Context -ModuleName SecurityPolicyResourceHelper
                }
            }
        }     
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment  
}
