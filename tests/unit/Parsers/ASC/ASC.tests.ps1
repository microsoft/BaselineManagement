$script:TestSourceRoot = "$PsScriptRoot"
$script:UnitTestRoot = (Get-ParentItem -Path $script:TestSourceRoot -Filter "unit" -Recurse -Directory).FullName
$script:SourceRoot = (Get-ParentItem -Path $script:TestSourceRoot -Filter "src" -Recurse -Directory).FullName
$script:ParsersRoot = "$script:SourceRoot\Parsers" 
$script:SampleRoot = "$script:UnitTestRoot\..\Samples"

$me = Split-Path -Path $script:TestSourceRoot -Leaf
$Parsers = Get-ChildItem -Filter '*.ps1' -Path (Join-Path -Path $script:ParsersRoot -ChildPath $me)

$Functions = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Functions.ps1")
$Enumerations = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Enumerations.ps1")

. $Functions.FullName
. $Enumerations.FullName
foreach ($Parser in $Parsers)
{
    . $Parser.FullName
}

$JSONSample = Join-Path -Path $script:SampleRoot -ChildPath "sample.json"

Import-Module PSDesiredStateConfiguration -Force

Write-Host -ForegroundColor White "ASC Parser Tests"
$JSON = Get-Content -Path $JSONSample | ConvertFrom-Json
$JSONBaselines = $JSON.properties.rulesetscollection.baselinerulesets.baselineName

Describe "Multiple Server Baselines" {    
    It "Can detect multiple server baselines" {
        $JSONBaselines | Should Not Be $Null
    }
    Write-Host "Discovered the Following Server Baselines:" -ForegroundColor White    
    $JSONBaselines | ForEach-Object { Write-Host "`t$_" -ForegroundColor White}
}
    
foreach ($BaselineName in $JSONBaselines)
{
    Write-Host "BASELINE: $baselineName" -ForegroundColor White
    $RULES = $JSON.properties.rulesetsCollection.baselineRulesets.Where( {$_.BaselineName -eq $BaselineName}).RULES
    
    $registryPolicies = $RULES.BaselineRegistryRules
    $AuditPolicies = $RULES.BaselineAuditPolicyRules
    $securityPolicies = $RULES.BaselineSecurityPolicyRules
    
    Describe "Write-ASCRegistryJSONData" {
        Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
        
        # Loop through all the registry settings.
        Foreach ($Policy in $registryPolicies)
        {
            $TypeHash = @{"Int" = "DWORD"; "String" = "String"}
            $Parameters = Write-ASCRegistryJSONData -RegistryData  $Policy 
            Context $Parameters.Name {
                It "Parses Regisry Data" {
                    If ($Parameters.CommentOut.IsPresent)
                    {
                        Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                    }
                    else
                    {
                        $Parameters.Type | Should Be "Registry"
                        Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                        $TypeHash = @{"Binary" = [byte]; "Dword" = [int]; "ExpandString" = [string]; "MultiString" = [string]; "Qword" = [string]; "String" = [string]}
                        ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                        $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                        [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                    }
                }
                
                switch ($Policy)
                {
                    {$_.RegValueType -eq "Int"}
                    {
                        It "Parses Integers Values Properly" {
                            $Parameters.Parameters.ValueData | Should BeOfType ([int]) # Should BeOfType?
                        }
                    }

                    {$_.RegValueType -eq "String"}
                    {
                        It "Parses String Values Properly" {
                            $Parameters.Parameters.ValueData | Should BeOfType ([string]) # Should BeOfType?
                        }
                    }
                    
                    {$_.RegValueType -eq "Binary"}
                    {        
                        <#It "Parses Binary Values Properly" {
                            $Parameters = Write-JSONRegistryData -RegistryData $JSON_Sample 
                        }#>
                    }

                    {!($_.State -eq "Enabled")}
                    {
                        It "Respects the Enabled Flag" {
                            $Parameters.CommentOUT | Should Be $true
                        }
                    }
                }
            }
        }
    }
    
    Describe "Write-ASCAuditJSONData" {
        Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ }
        foreach ($Policy in $auditPolicies)
        {
            $Parameters = Write-ASCAuditJSONData -AuditData $Policy 
            
            switch ($Policy.ExpectedValue)
            {
                "SuccessAndFailure"
                {
                    It "Parses SuccessAndFailure separately" {
                        $Parameters.Count | Should Be 2
                    }
                    $Success = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Success"})
                    $Failure = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Failure"})
                    
                    Context $Success.Name {
                        It "Separates out the SuccessBlock" {
                            $Success.Type | Should Be AuditPolicySubcategory
                            $Success.Parameters.SubCategory | Should Be $AuditCategoryHash[$Policy.AuditPolicyId]
                            $Success.Parameters.AuditFlag | Should Be "Success"
                            $Success.Parameters.Ensure | Should Be "Present"
                            [string]::IsNullOrEmpty($Success.Name) | Should Be $false
                        }
                    }

                    Context $Failure.Name {
                        It "Separates out the FailureBlock" {
                            $Failure.Type | Should Be AuditPolicySubcategory
                            $Failure.Parameters.SubCategory | Should Be $AuditCategoryHash[$Policy.AuditPolicyId]
                            $Failure.Parameters.AuditFlag | Should Be "Failure"
                            $Failure.Parameters.Ensure | Should Be "Present"
                            [string]::IsNullOrEmpty($Failure.Name) | Should Be $false
                        }
                    }
                }

                "NoAuditing"
                {
                    It "Parses NoAuditing separately" {
                        $Parameters.Count | Should Be 2
                    }
                                        
                    $Success = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Success"})
                    $Failure = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Failure"})
                    
                    Context $Success.Name {
                        It "Separates out the SuccessBlock" {
                            $Success.Type | Should Be AuditPolicySubcategory
                            $Success.Parameters.SubCategory | Should Be $AuditCategoryHash[$Policy.AuditPolicyId]
                            $Success.Parameters.AuditFlag | Should Be "Success"
                            $Success.Parameters.Ensure | Shoud Be "Absent"
                            [string]::IsNullOrEmpty($Success.Name) | Should Be $false
                        }
                    }

                    Context $Failure.Name {
                        It "Separates out the FailureBlock" {
                            $Failure.Type | Should Be AuditPolicySubcategory
                            $Failure.Parameters.SubCategory | Should Be $AuditCategoryHash[$Policy.AuditPolicyId]
                            $Failure.Parameters.AuditFlag | Should Be "Failure"
                            $Failure.Parameters.Ensure | Should Be "Absent"
                            [string]::IsNullOrEmpty($Failure.Name) | Should Be $false
                        }
                    }
                }

                Default
                {
                    Context $Parameters.Name {
                        It "Parses Audit Data" {
                            $Parameters.Type | Should Be AuditPolicySubcategory
                            $Parameters.Parameters.SubCategory | Should Be $AuditCategoryHash[$Policy.AuditPolicyId]
                            $Parameters.Parameters.AuditFlag | Should Be $Policy.ExpectedValue.Trim()
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                        }
                    }
                }
            }
            
            if (!$Policy.State -eq "Enabled")
            {
                It "Respects the Enabled Flag" {
                    $Parameters.CommentOUT | Should Be $True
                }
            }
        }
    }
    
    Describe "Write-ASCPrivilegeJSONData" {
        Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
        
        foreach ($Policy in $securityPolicies)
        {
            $Parameters = Write-ASCPrivilegeJSONData -PrivilegeData $Policy 
            Context $Parameters.Name {                    
                switch ($Policy.SectionName)
                {
                    "Service General Setting"
                    {

                    }

                    "Registry Values"
                    {

                    }

                    "File Security"
                    {

                    }
                    
                    "Privilege Rights"
                    {            
                        It "Parses Privilege Data" {
                            $Parameters.Type | Should Be "UserRightsAssignment"
                            $Parameters.Parameters.Policy | Should Be $UserRightsHash[$Policy.SettingName]
                            $Policy.ExpectedValue = $Policy.ExpectedValue -replace "NT AUTHORITY\\Local account and member of Administrators group", "[Local Account|Administrator]" 
                            $Policy.ExpectedValue = $Policy.ExpectedValue -replace "NT AUTHORITY\\Local account", "[Local Account]"
                            $Parameters.Parameters.Identity -join ", " | Should Match (((($Policy.ExpectedValue -replace "No One", "") -split ", ") | ForEach-Object {"(?=.*$_)"}) -join "")
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                        }
                    }
                    
                    "Kerberos Policy"
                    {
                    
                    }
                    
                    "Registry Keys"
                    {

                    }
                    
                    "System Access"
                    {

                    }
                }      
            }

            if (!$Policy.State -eq "Enabled")
            {
                It "Respects the Enabled Flag" {
                    $Parameters.CommentOUT | Should be $true
                }
            }
        }
    }
}
