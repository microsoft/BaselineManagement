Write-Host "`n"
Write-Host "Paths" -ForegroundColor Green
Write-Host "--------------------"
Write-Host "PSScriptRoot: $PSScriptRoot"
$script:UnitTestRoot = Get-Item $PSScriptRoot | ForEach-Object Parent | ForEach-Object Parent | ForEach-Object FullName
Write-Host "UnitTestRoot: $script:UnitTestRoot"
$script:SourceRoot = Join-Path -Path (get-item $script:UnitTestRoot | ForEach-Object Parent | ForEach-Object Parent | ForEach-Object FullName) -ChildPath 'src'
Write-Host "SourceRoot: $script:SourceRoot"
$script:ParsersRoot = "$script:SourceRoot\Parsers" 
Write-Host "ParsersRoot: $script:ParsersRoot"
$script:SampleRoot = "$script:UnitTestRoot\..\Samples"
Write-Host "SampleRoot: $script:SampleRoot"
Write-Host "`n"
$SamplePOL = Join-Path $script:SampleRoot "Registry.Pol"
$SampleGPTemp = Join-Path $script:SampleRoot "gptTmpl.inf"
$SampleAuditCSV = Join-Path $script:SampleRoot "audit.csv"

$Parsers = Get-ChildItem -Filter '*.ps1' -Path $script:ParsersRoot/GPO

Write-Host "Parsers" -ForegroundColor Green
Write-Host "--------------------"
foreach ($p in $Parsers) {Write-Host $p.Name"`t" -NoNewline}
Write-Host "`n"

Write-Host "Available DSC modules" -ForegroundColor Green
Write-Host "--------------------"
foreach ($m in (Get-DSCResource | % ModuleName | Select -Unique)) {
    $r = Get-DSCResource -Module $m | % Name
    Write-Host $m"`t("$r")"
}
Write-Host "`n"

$Functions = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Functions.ps1")
$Enumerations = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Enumerations.ps1")

. $Functions.FullName
. $Enumerations.FullName
foreach ($Parser in $Parsers)
{
    . $Parser.FullName
}

Import-Module PSDesiredStateConfiguration -Force

Write-Host "`nGPO Parser Tests" -ForegroundColor White

Describe "Write-GPOAuditCSVData" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    $auditData = Import-CSV -Path $SampleAuditCSV

    foreach ($Entry in $auditData)
    {
        if ($Entry.'Subcategory' -match "(GlobalSACL|Option:)")
        {
            # Adding Separate tests for these.
            continue
        }

        $Parameters = Write-GPOAuditCSVData -Entry $Entry

        switch -regex ($Entry."Inclusion Setting")
        {
            "Success and Failure"
            {
                It "Parses SuccessAndFailure separately" {
                    $Parameters.Count | Should -Be 2
                }
                                    
                $Success = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Success" })
                $Failure = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Failure" })
                
                Context "Success $($Success.Name)" {
                    It "Separates out the SuccessBlock" {
                        $Success.Type | Should -Be AuditPolicySubcategory
                        $Success.Parameters.SubCategory | Should -Be $Entry.Name
                        $Success.Parameters.AuditFlag | Should -Be "Success"
                        $Success.Parameters.Ensure | Should -Be "Present"
                        [string]::IsNullOrEmpty($Success.Name) | Should -Be $false
                    }
                }

                Context "Failure $($Failure.Name)" {
                    It "Separates out the FailureBlock" {
                        $Failure.Type | Should -Be AuditPolicySubcategory
                        $Failure.Parameters.SubCategory | Should -Be $Entry.Name
                        $Failure.Parameters.AuditFlag | Should -Be "Failure"
                        $Failure.Parameters.Ensure | Should -Be "Present"
                        [string]::IsNullOrEmpty($Failure.Name) | Should -Be $false
                    }
                }
            }

            "No Auditing"
            {
                It "Parses NoAuditing separately" {
                    $Parameters.Count | Should -Be 2
                }
                                    
                $Success = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Success" })
                $Failure = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Failure" })
                
                Context $Success.Name {
                    It "Separates out the SuccessBlock" {
                        $Success.Type | Should -Be AuditPolicySubcategory
                        $Success.Parameters.SubCategory | Should -Be $Entry.Name
                        $Success.Parameters.AuditFlag | Should -Be "Success"
                        $Success.Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Success.Name) | Should -Be $false
                    }
                }

                Context $Failure.Name {
                    It "Separates out the FailureBlock" {
                        $Failure.Type | Should -Be AuditPolicySubcategory
                        $Failure.Parameters.SubCategory | Should -Be $Entry.Name
                        $Failure.Parameters.AuditFlag | Should -Be "Failure"
                        $Failure.Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Failure.Name) | Should -Be $false
                    }
                }
            }

            "^Success$"
            {
                It "Creates an opposite Failure Entry for Succes" {
                    $Parameters.Count | Should -Be 2
                }
                
                $Success = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Success" })
                $Failure = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Failure" })

                Context $Success.Name {
                    It "Creates the SuccessBlock" {
                        $Success.Type | Should -Be AuditPolicySubcategory
                        $Success.Parameters.SubCategory | Should -Be $Entry.Name
                        $Success.Parameters.AuditFlag | Should -Be "Success"
                        $Success.Parameters.Ensure | Should -Be "Present"
                        [string]::IsNullOrEmpty($Success.Name) | Should -Be $false
                    }
                }

                Context $Failure.Name {
                    It "Creates the FailureBlock" {
                        $Failure.Type | Should -Be AuditPolicySubcategory
                        $Failure.Parameters.SubCategory | Should -Be $Entry.Name
                        $Failure.Parameters.AuditFlag | Should -Be "Failure"
                        $Failure.Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Failure.Name) | Should -Be $false
                    }
                }
            }

            "^Failure$"
            {
                It "Creates an opposite Success Entry for Failure" {
                    $Parameters.Count | Should -Be 2
                }
                
                $Success = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Success" })
                $Failure = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Failure" })

                Context $Success.Name {
                    It "Creates the SuccessBlock" {
                        $Success.Type | Should -Be AuditPolicySubcategory
                        $Success.Parameters.SubCategory | Should -Be $Entry.Name
                        $Success.Parameters.AuditFlag | Should -Be "Success"
                        $Success.Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Success.Name) | Should -Be $false
                    }
                }

                Context $Failure.Name {
                    It "Creates the FailureBlock" {
                        $Failure.Type | Should -Be AuditPolicySubcategory
                        $Failure.Parameters.SubCategory | Should -Be $Entry.Name
                        $Failure.Parameters.AuditFlag | Should -Be "Failure"
                        $Failure.Parameters.Ensure | Should -Be "Present"
                        [string]::IsNullOrEmpty($Failure.Name) | Should -Be $false
                    }
                }
            }
        }
        
        switch -regex ($Entry."Exclusion Setting")
        {
            "Success and Failure"
            {
                It "Parses SuccessAndFailure separately" {
                    $Parameters.Count | Should -Be 2
                }
                                    
                $Success = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Success" })
                $Failure = $Parameters.Where( { $_.Parameters.AuditFlag -eq "Failure" })
                
                Context $Success.Name {
                    It "Separates out the SuccessBlock" {
                        $Success.Type | Should -Be AuditPolicySubcategory
                        $Success.Parameters.SubCategory | Should -Be $Entry.Name
                        $Success.Parameters.AuditFlag | Should -Be "Success"
                        $Success.Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Success.Name) | Should -Be $false
                    }
                }

                Context $Failure.Name {
                    It "Separates out the FailureBlock" {
                        $Failure.Type | Should -Be AuditPolicySubcategory
                        $Failure.Parameters.SubCategory | Should -Be $Entry.Name
                        $Failure.Parameters.AuditFlag | Should -Be "Failure"
                        $Failure.Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Failure.Name) | Should -Be $false
                    }
                }
            }

            "No Auditing"
            {
                # I am not sure how to make sure that "No Auditing" is Excluded or ABSENT. What should it be set to then?
            }

            "^(Success|Failure)$"
            {
                Context $Parameters.Name {
                    It "Parses Audit Data" {
                        $Parameters.Type | Should -Be AuditPolicySubcategory
                        $Parameters.Parameters.SubCategory | Should -Be $Entry.Name
                        $Parameters.Parameters.AuditFlag | Should -Be $_
                        $Parameters.Ensure | Should -Be "Absent"
                        [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                    }
                }
            }
        }
    }
}

Describe "Write-GPORegistryPOLData" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    if ((Get-Command "Read-PolFile" -ErrorAction SilentlyContinue) -ne $null)
    {
        # Reaad each POL file found.
        Write-Verbose "Reading Pol File ($($SamplePol))"
        Try
        {
            $registryPolicies = Read-PolFile -Path $SamplePol
        }
        Catch
        {
            Write-Error $_
        }
    }
    elseif ((Get-Command "Parse-PolFile" -ErrorAction SilentlyContinue) -ne $null)
    {
        # Reaad each POL file found.
        Write-Verbose "Reading Pol File ($($SamplePol))"
        Try
        {
            $registryPolicies = Parse-PolFile -Path $SamplePol
        }
        catch
        {
            Write-Error $_ 
        }
    }
    else
    {
        Write-Error "Cannot Parse Pol files! Please download and install GPRegistryPolicyParser from github here: https://github.com/PowerShell/GPRegistryPolicyParser"
        break
    }

    It "Parses Registry Policies" {
        $registryPolicies | Should Not Be $Null
    }

    foreach ($Policy in $registryPolicies)
    {
        $Parameters = Write-GPORegistryPOLData -Data $Policy
        Context $Parameters.Name {
            It "Parses Registry Data" {
                If ($Parameters.CommentOut.IsPresent)
                {
                    Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                }
                else
                {
                    $Parameters.Type | Should -Be "RegistryPolicyFile"
                    Test-Path -Path $Parameters.Parameters.Key -IsValid | Should -Be $true
                    $TypeHash = @{"Binary" = [string]; "Dword" = [int]; "ExpandString" = [string]; "MultiString" = [string]; "Qword" = [string]; "String" = [string] }
                    if ($Parameters.Name.StartsWith("DELVAL"))
                    {
                        if ($ExlusiveFlagAvailable)
                        {
                            $Parameters.Parameters.Ensure | Should -Be "Absent"
                        }
                        else
                        {
                            $Parameters.CommentOUT | Should -Be $True
                        }
                    }
                    elseif ($Parameters.Name.StartsWith("DEL"))
                    {
                        $Parameters.Parameters.Ensure | Should -Be "Absent"
                    }
                    elseif ($Parameters.Parameters.ContainsKey("ValueType"))
                    {
                        ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should -Be $true 
                    }
                    
                    if ($Parameters.Parameters.ContainsKey("ValueData"))
                    {
                        $Parameters.Parameters.ValueData | Should -BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                    }

                    [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                }
            }
        }
    }
}
    
Describe "GPtTempl.INF Data" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    $ini = Get-IniContent $SampleGPTemp

    It "Parses INF files" {
        { Get-IniContent $SampleGPTemp } | Should Not Throw
        $ini | Should Not Be $null
    }

    # Loop through every heading.
    foreach ($key in $ini.Keys)
    {
        # Loop through every setting in the heading.
        foreach ($subKey in $ini[$key].Keys)
        {
            switch ($key)
            {
                "Service General Setting"
                {
                    $Parameters = Write-GPOServiceINFData -Service $subkey -ServiceData $ini[$key][$subKey]
                    Context $Parameters.Name {    
                        It "Parses Service Data" {
                            $Parameters.Type | Should -Be "Service"
                        }
                    }
                }

                "Registry Values"
                {
                    $Parameters = Write-GPORegistryINFData -Key $subkey -ValueData $ini[$key][$subKey]
                    Context $Parameters.Name {
                        It "Parses Registry Values" {
                            If ($Parameters.CommentOut.IsPresent)
                            {
                                Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                            }
                            else
                            {
                                $Parameters.Type | Should -Be "RegistryPolicyFile"
                                [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should -Be $false
                                Test-Path -Path $Parameters.Parameters.Key -IsValid | Should -Be $true
                                $TypeHash = @{"Binary" = [string]; "Dword" = [int]; "ExpandString" = [string]; "MultiString" = [string]; "Qword" = [string]; "String" = [string] }
                                ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should -Be $true
                                $Parameters.Parameters.ValueData | Should -BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                                [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                            }
                        }
                    }
                }

                "File Security"
                {
                    $Parameters = Write-GPOFileSecurityINFData -Path $subkey -ACLData $ini[$key][$subKey]
                    Context $Parameters.Name {
                        It "Parses File ACL Data" {
                            $Parameters.Type | Should -Be NtfsAccessEntry
                            [String]::IsNullOrEmpty($Parameters.Parameters.sddl) | Should -Be $false
                            Test-PAth -Path "$($Parameters.Parameters.Path)" -IsValid | Should -Be $true
                            [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                        }
                    }
                }
            
                "Privilege Rights"
                {
                    $Parameters = Write-GPOPrivilegeINFData -Privilege $subkey -PrivilegeData $ini[$key][$subKey]
                    Context $Parameters.Name {
                        It "Parses Privilege Data" {
                            $Parameters.Type | Should -Be "UserRightsAssignment"
                            [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                            $UserRightsHash.Values -contains $Parameters.Parameters.Policy | Should -Be $true
                        }
                    }
                }

                "Kerberos Policy"
                {
                    $Parameters = Write-GPOSecuritySettingINFData -Key $subKey -SecurityData $ini[$key][$subkey]
                    Context $Parameters.Name {
                        It "Parses Kerberos Data" {
                            $Parameters.Type | Should -Be "SecuritySetting"
                            [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                            $SecuritySettings -contains $Parameters.Parameters.Name | Should -Be $true
                            $Parameters.Parameters.ContainsKey($Parameters.Parameters.Name) | Should -Be $true
                        }
                    }
                }
            
                "Registry Keys"
                {
                    $Parameters = Write-GPORegistryACLINFData -Path $subkey -ACLData $ini[$key][$subKey]
                    
                    Context $Parameters.Name {
                        It "Parses Registry ACL Data" {
                            [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                            Test-Path -Path $Parameters.Parameters.Path -IsValid | Should -Be $true
                            $Parameters.Parameters.ObjectType | Should -Be "RegistryKey"
                            [string]::IsNullOrEmpty($Parameters.Parameters.Sddl) | Should -Be $false
                        }
                    }
                }
            
                "System Access"
                {
                    $Parameters = Write-GPOSecuritySettingINFData -Key $subKey -SecurityData $ini[$key][$subkey]
                    if ($Parameters -ne "")
                    {
                        Context $Parameters.Name {                        
                            It "Parses System Access Settings" {
                                $Parameters.Type | Should -Be "SecuritySetting"
                                [string]::IsNullOrEmpty($Parameters.Name) | Should -Be $false
                                $SecuritySettings -contains $Parameters.Parameters.Name | Should -Be $true
                                $Parameters.Parameters.ContainsKey($Parameters.Parameters.Name) | Should -Be $true
                            }
                        }
                    }
                }

                "Event Auditing"
                {

                }
            }
        }
    }
}
