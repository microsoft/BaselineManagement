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
$Global:DSCResourceName    = 'MSFT_xAuditCategory'

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

# the audit option to use in the tests
$Subcategory   = 'logon'
$AuditFlag     = 'Failure'
$MockAuditFlags = 'Success','Failure','SuccessandFailure','NoAuditing'
$AuditFlagSwap = @{'Failure'='Success';'Success'='Failure'}

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
            
            Context "Return object " {
                
                # mock call to the helper module to isolate Get-TargetResource
                Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlag} } -ModuleName MSFT_xAuditCategory

                $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

                    It " is a hashtable that has the following keys:" {
                        $isHashtable = $Get.GetType().Name -eq 'hashtable'

                        $isHashtable | Should Be $true
                    }
            
                    It "  Subcategory" {
                        $ContainsSubcategoryKey = $Get.ContainsKey('Subcategory') 
                
                        $ContainsSubcategoryKey | Should Be $true
                    }

                    It "  AuditFlag" {
                        $ContainsAuditFlagKey = $Get.ContainsKey('AuditFlag') 
                
                        $ContainsAuditFlagKey | Should Be $true
                    }

                    It "  Ensure" {
                        $ContainsEnsureKey = $Get.ContainsKey('Ensure') 
                
                        $ContainsEnsureKey| Should Be $true
                    }
            }

            Context "Submit '$AuditFlag' and return '$AuditFlag'" {

                # mock call to the helper module to isolate Get-TargetResource
                Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlag} } -ModuleName MSFT_xAuditCategory

                $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

                It " 'Subcategory' = '$Subcategory'" {
                    $RetrievedSubcategory =  $Get.Subcategory 
                
                    $RetrievedSubcategory | Should Be $Subcategory
                }
                    
                It " 'AuditFlag' = '$AuditFlag'" {
                    $RetrievedAuditFlag = $Get.AuditFlag 
                
                    $RetrievedAuditFlag | Should Match $AuditFlag
                }

                It " 'Ensure' = 'Present'" {
                    $RetrievedEnsure = $Get.Ensure 
                
                    $RetrievedEnsure | Should Be 'Present'
                }
            }

            Context "Submit '$AuditFlag' and return '$($AuditFlagSwap[$AuditFlag])'" {
            
                # mock call to the helper module to isolate Get-TargetResource
                Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlagSwap[$AuditFlag]} } -ModuleName MSFT_xAuditCategory

                $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

                It " 'Subcategory' = '$Subcategory'" {
                    $RetrievedSubcategory =  $Get.Subcategory 
                
                    $RetrievedSubcategory | Should Be $Subcategory
                }
                    
                It " 'AuditFlag' != '$AuditFlag'" {
                    $RetrievedAuditFlag = $Get.AuditFlag 
                
                    $RetrievedAuditFlag | Should Not Match $AuditFlag
                }

                It " 'Ensure' = 'Absent'" {
                    $RetrievedEnsure = $Get.Ensure 
                
                    $RetrievedEnsure | Should Be 'Absent'
                }
            }

            Context "Submit '$AuditFlag' and return 'NoAuditing'" {

                Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'='NoAuditing'} } -ModuleName MSFT_xAuditCategory

                $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag
            
                It " 'Subcategory' = '$Subcategory'" {
                    $RetrievedSubcategory =  $Get.Subcategory 
                
                    $RetrievedSubcategory | Should Be $Subcategory
                }

                It " 'AuditFlag' != '$AuditFlag'" {
                    $RetrievedAuditFlag = $Get.AuditFlag 
                
                    $RetrievedAuditFlag | Should Not Match $AuditFlag
                }


                It " 'Ensure' = 'Absent'" {
                    $RetrievedEnsure = $Get.Ensure 
                
                    $RetrievedEnsure | Should Be 'Absent'
                }

            }

            Context "Submit '$AuditFlag' and return 'SuccessandFailure'" {

                Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'='SuccessandFailure'} } -ModuleName MSFT_xAuditCategory

                $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag
            
                It " 'Subcategory' = '$Subcategory'" {
                    $RetrievedSubcategory =  $Get.Subcategory 
                
                    $RetrievedSubcategory | Should Be $Subcategory
                }

                It " 'AuditFlag' = '$AuditFlag'" {
                    $RetrievedAuditFlag = $Get.AuditFlag 
                
                    $RetrievedAuditFlag | Should Be $AuditFlag
                }


                It " 'Ensure' = 'Present'" {
                    $RetrievedEnsure = $Get.Ensure 
                
                    $RetrievedEnsure | Should Be 'Present'
                }

            }

            Context "Validate support function(s) in helper module" {

                $Function = ((Get-Module -All 'Helper').ExportedCommands['Get-AuditCategory'])

                It " Found function 'Get-AuditCategory'" {
                    $FunctionName = $Function.Name
        
                    $FunctionName | Should Be 'Get-AuditCategory'
                }

                It " Found parameter 'Subcategory'" {
                    $Subcategory = $Function.Parameters['Subcategory'].name
        
                    $Subcategory | Should Be 'Subcategory'
                }
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            # mock call to the helper module to isolate Get-TargetResource
            Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlag} } -ModuleName MSFT_xAuditCategory
            
            $testResult = Test-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag -Ensure "Present"
    
            It "Returns an Object of type Boolean" {
                
                $isBool = $testResult.GetType().Name -eq 'Boolean'
                $isBool | Should Be $true
            }

            It " that is True when the Audit flag is Present and should be Present" {
                
                $testResult | Should Be $true
            }

            It " and False when the Audit flag is Absent and should be Present" {
                
                $testResult = Test-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag -Ensure "Absent"
                $testResult | Should Be $false

                Assert-MockCalled Get-AuditCategory -Exactly 1 -Scope It
            }

            
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            
            Mock Set-AuditCategory { return }

            Context 'Return object' {
                $set = Set-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

                It 'is Empty' {
                    $set | Should BeNullOrEmpty
                }
            }

            Context 'Mandatory parameters' {
                
                It 'AuditFlag is mandatory ' {
                    {
                        Set-TargetResource -Subcategory $Subcategory -AuditFlag
                    } | Should Throw
                }

                It 'Subcategory is mandatory ' {
                    {
                        Set-TargetResource -Subcategory  -AuditFlag $AuditFlag
                    } | Should Throw
                }
            }

            Context "Validate support function(s) in helper module" {
                
                $functionName = 'Set-AuditCategory'
                $Function = ((Get-Module -All 'Helper').ExportedCommands[$functionName])

                It " Found function $functionName" {
                    $FunctionName = $Function.Name
        
                    $FunctionName | Should Be $functionName
                }

                It " Found parameter 'Subcategory'" {
                    $Subcategory = $Function.Parameters['Subcategory'].name
        
                    $Subcategory | Should Be 'Subcategory'
                }
            }
        }
        #endregion

        # Pester Tests for any Helper Cmdlets

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
