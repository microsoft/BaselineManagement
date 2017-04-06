<############################################################################################ 
 # File: BaselineManagement\HelperFunctions.psm1
 # This suite contains Tests that are
 # used for validating the BaselineManagement Module.
 ############################################################################################>
$script:TestSourceRoot = $PSScriptRoot
$ModuleBase = Split-Path $script:TestSourceRoot

$HelperModule = Join-Path $ModuleBase 'HelperFunctions.psm1'
$SampleXML = Join-Path $ModuleBase 'Tests\Sample.XML'
$SamplePOL = Join-Path $ModuleBase "Tests\Registry.Pol"
$SampleGPTemp = Join-Path $ModuleBase "Tests\gptTmpl.inf"
$SampleComment = Join-Path $ModuleBase "Tests\Comment.cmtx"
$SampleREGXML = Join-Path $ModuleBase "Tests\Registry.xml"
$JSONSample = Join-Path $ModuleBase "Tests\sample.json"

Import-Module $HelperModule -Force
Import-Module PSDesiredStateConfiguration -Force
Import-Module Pester -Force

Describe "DSC String Helper Tests" {
    Context "Write-DSCString" {
        
        # This only works when it feels like it.
        Mock Get-DSCResource -ParameterFilter { $Module -eq "TestModule_01"} -Verifiable { return [psobject]@{Name="TestResource_01";Properties=@(@{Name="Name";IsMandatory=$true}, @{Name="Value";IsMandatory=$true})}}
        Mock Get-DSCResource -ParameterFilter { $Module -eq "TestModule_02"} -Verifiable { return [psobject]@{Name="TestResource_02";Properties=@(@{Name="Name";IsMandatory=$true}, @{Name="Value";IsMandatory=$true})}}

        $CONFIG_Params = @{Configuration=$true;Name="TestConfig"}
        $CONFIG_ModuleParams = @{ModuleName = @("PSDesiredStateConfiguration");ModuleImport=$true}
        $CONFIG_Node = @{Node=$true;Name="localhost"}
        $CONFIG_ResourceParams = @{Resource=$true;Type="Registry";Name="Test";Parameters=@{Key="HKLM:\SOFTWARE";ValueName = "TestResource";ValueData="Test";ValueType="DWORD" }}
        $CONFIG_Invoke = @{InvokeConfiguration=$true;Name="TestConfig";OutputPath=$(Join-Path -Path "C:\Temp" -ChildPath Output)}
        
        It "Creates a Configuration Open Block" {
            Write-DSCString @CONFIG_Params | Should Match "Configuration $($CONFIG_Params.Name)`n{`n`n`t" 
        }

        $CONFIG_Params.Add("Comment", "Test Comment")
        It "Comments a Configuration Open Block" {
            Write-DSCString @CONFIG_Params | Should Match "<#`n$($CONFIG_Params.Comment)`n#>" 
        }

        It "Creates Module Import Strings" {
            Write-DSCString @CONFIG_ModuleParams | Should Match "(?s)$(($CONFIG_ModuleParams.ModuleName | %{"'$_'"}) -join ", ")"
            #Assert-MockCalled -CommandName Get-DscResource -Times 2
        }

        It "Creates a Resource Block" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?m)$($CONFIG_ResourceParams.Type) '$($CONFIG_ResourceParams.Name)'.*$((($CONFIG_ResourceParams.Parameters.GetEnumerator() | %{"$($_.Key) = '$($_.Value)'"}) -join '|')*4)}"
        }

        It "Parses String Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)'$($CONFIG_ResourceParams.Parameters.ValueData)'"
        }

        [int]$CONFIG_ResourceParams.Parameters.ValueData = 3
        It "Parses Integer Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)$($CONFIG_ResourceParams.Parameters.ValueData)"
        }

        [bool]$CONFIG_ResourceParams.Parameters.ValueData = $True
        It "Parses Boolean Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)\`$$($CONFIG_ResourceParams.Parameters.ValueData)"
        }

        [string[]]$CONFIG_ResourceParams.Parameters.ValueData = "One", "Two", "Three"
        It "Parses Array String Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)$(($CONFIG_ResourceParams.Parameters.ValueData | %{"'$_'"}) -join ", ")"
        }

        [int[]]$CONFIG_ResourceParams.Parameters.ValueData = 1,2,3
        It "Parses Array Integer Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)$(($CONFIG_ResourceParams.Parameters.ValueData | %{"$_"}) -join ", ")"
        }

        It "Detects Resource Conflicts" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)<#$($CONFIG_ResourceParams.Type).*}#>" 
        }

        $CONFIG_ResourceParams.Add("CommentOUT", $True)
        It "Comments out Resources when asked" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)<#$($CONFIG_ResourceParams.Type).*}#>" 
        }

        It "Creates Node Blocks" {
            Write-DSCString @CONFIG_Node | Should Match "Node $($CONFIG_Node.Name)`n`t{`n"
        }

        It "Closes Configuration Blocks" {
            Write-DSCString -CloseConfigurationBlock | Should Match "`n}`n"
        }

        It "Closes Node Blocks" {
            Write-DSCString -CloseNodeBlock | Should Match "`t}"
        }

        It "Creates Invoke Configuration Strings" {
            Write-DSCString @CONFIG_Invoke | Should Match "$($CONFIG_Invoke.Name) -OutputPath '$($CONFIG_Invoke.OutputPath.Replace("\", "\\"))'"
        }
    }
    
    Context "Complete-Configuration" {
        Mock -Verifiable -CommandName Get-PSCallStack { return [psobject]@(@{Command="None"}, @{Command="PesterTest"}) }
        $Configuration = @"
Configuration Test
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Node localhost
    {
        Service Spooler
        {
            Name = 'Spooler'
            State = 'Running'
        }
    }
}

Test -OutputPath $($script:TestSourceRoot)
"@
    $Configuration_ERROR = @"
Configuration Test
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Node localhost
    {
        Service Spooler
        {
            State = 'Running'
        }
    }
}

Test -OutputPath $($script:TestSourceRoot)
"@
        It "Compiles a Configuration" {
            Complete-Configuration -ConfigString $Configuration -OutputPath $script:TestSourceRoot
            $MOF = (Join-Path -Path $script:TestSourceRoot -ChildPath "localhost.mof")
            $MOF | Should Exist
            Remove-Item $MOF 
        }

        It "Creates Error files on Failure" {
            Complete-Configuration -ConfigString $Configuration_ERROR -OutputPath $script:TestSourceRoot -ErrorAction SilentlyContinue
            $ErrorFile = (Join-Path -Path $script:TestSourceRoot -ChildPath "WTF.ps1.error")
            $ErrorFile | Should Exist
            Remove-Item $ErrorFile
        }
    }
}

Describe "GPO Conversion Helper Tests" {
    
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } -ModuleName HelperFunctions

    Context "Comment.cmtx Data" {
        Write-Warning "Not Implemented Yet"
    }

    Context "Write-GPORegistryXMLData" {
        [xml]$RegistryXML = Get-Content $SampleREGXML

        $Settings = $RegistryXML.RegistrySettings.Registry

        It "Parses Registry XML" {
            $Settings | Should Not Be $Null
        }
        
        # Loop through every registry setting.
        foreach ($Setting in $Settings)
        {
            $Parameters = Write-GPORegistryXMLData -XML $Setting
            Write-Host $Parameters.Name

            It "Parses Registry XML Data" {
                    If ($Parameters.CommentOut.IsPresent)
                    {
                        Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                    }
                    else
                    {
                        $Parameters.Type | Should Be "Registry"
                        [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should Be $false
                        Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                        $TypeHash = @{"Binary"=[byte];"Dword"=[int];"ExpandString"=[string];"MultiString"=[string];"Qword"=[string];"String"=[string]}
                        ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                        $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                        [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                    }
                }
        }
    }

    Context "Write-POLRegistryData" {
        $registryPolicies = Read-PolFile -Path $SamplePOL

        It "Parses Registry Policies" {
            $registryPolicies | Should Not Be $Null
        }

        foreach ($Policy in $registryPolicies)
        {
            $Parameters = Write-POLRegistryData -Data $Policy
            Write-Host $Parameters.Name

            It "Parses Registry Data" {
                    If ($Parameters.CommentOut.IsPresent)
                    {
                        Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                    }
                    else
                    {
                        $Parameters.Type | Should Be "Registry"
                        [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should Be $false
                        Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                        $TypeHash = @{"Binary"=[byte];"Dword"=[int];"ExpandString"=[string];"MultiString"=[string];"Qword"=[string];"String"=[string]}
                        ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                        $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                        [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                    }
                }
        }
    }
        
    Context "GPtTempl.INF Data" {
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
                        It "Parses Service Data" {
                            $Parameters = Write-INFServiceData -Service $subkey -ServiceData $ini[$key][$subKey]
                            Write-Host $Parameters.Name
                        }
                    }

                    "Registry Values"
                    {
                        It "Parses Registry Values" {
                            If ($Parameters.CommentOut.IsPresent)
                            {
                                Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                            }
                            else
                            {
                                $Parameters = Write-INFRegistryData -Key $subkey -ValueData $ini[$key][$subKey]
                                Write-Host $Parameters.Name
                                $Parameters.Type | Should Be "Registry"
                                [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should Be $false
                                Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                                $TypeHash = @{"Binary"=[byte];"Dword"=[int];"ExpandString"=[string];"MultiString"=[string];"Qword"=[string];"String"=[string]}
                                ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                                $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                                [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                            }
                        }
                    }

                    "File Security"
                    {
                        It "Parses File ACL Data" {
                            $Parameters = Write-INFFileSecurityData -Path $subkey -ACLData $ini[$key][$subKey]
                            Write-Host $Parameters.Name
                            $Parameters.Type | Should Be xACL
                            [String]::IsNullOrEmpty($Parameters.Parameters.DACLString) | Should Be $false
                            Test-PAth -Path "$($Parameters.Parameters.Path)" -IsValid | Should Be $true
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                        }
                    }
                
                    "Privilege Rights"
                    {
                        It "Parses Privilege Data" {
                            $Parameters = Write-INFPrivilegeData -Privilege $subkey -PrivilegeData $ini[$key][$subKey]
                            Write-Host $Parameters.Name
                            $Parameters.Type | Should Be "UserRightsAssignment"
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                            $UserRightsHash.Values -contains $Parameters.Parameters.Policy | Should Be $true
                        }
                    }
                
                    "Kerberos Policy"
                    {
                        It "Parses Kerberos Data" {
                            $Parameters = Write-INFSecuritySettingData -Key $subKey -SecurityData $ini[$key][$subkey]
                            Write-Host $Parameters.Name
                            $Parameters.Type | Should Be "SecuritySetting"
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                            $SecuritySettings -contains $Parameters.Parameters.Name | Should Be $true
                            $Parameters.Parameters.ContainsKey($Parameters.Parameters.Name) | Should Be $true
                        }
                    }
                
                    "Registry Keys"
                    {
                        It "Parses Registry ACL Data" {
                            $Parameters = Write-INFRegistryACLData -Path $subkey -ACLData $ini[$key][$subKey]
                            Write-Host $Parameters.Name
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                            Test-Path -Path $Parameters.Parameters.Path -IsValid | Should Be $true
                            [string]::IsNullOrEmpty($Parameters.Parameters.DACLString) | SHould Be $false
                        }
                    }
                
                    "System Access"
                    {
                        It "Parses System Access Settings" {
                            $Parameters = Write-INFSecuritySettingData -Key $subKey -SecurityData $ini[$key][$subkey]
                            Write-Host $Parameters.Name
                            $Parameters.Type | Should Be "SecuritySetting"
                            [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                            $SecuritySettings -contains $Parameters.Parameters.Name | Should Be $true
                            $Parameters.Parameters.ContainsKey($Parameters.Parameters.Name) | Should Be $true
                        }
                    }
                }
            }
        }
    }
}

Describe "XML Conversion Helper Tests" {
    
    [XML]$XML = Get-Content $SampleXML
    
    # We need to setup a namespace to properly search the XML.
    $namespace = @{e="http://schemas.microsoft.com/SolutionAccelerator/SecurityCompliance"}
    
    # Grab all the DiscoveryInfo objects in the XML. They determine how to find the setting in question.
    $results = (Select-XML -XPath "//e:SettingDiscoveryInfo" -Xml $xml -Namespace $namespace).Node

    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } -ModuleName HelperFunctions
    
    It "Parses XML into DiscoveryInfo Objects" {
        $results | Should Not Be $null
    }

    Function Get-ValueNodeData 
    {
        param
        (
            [System.Xml.XmlElement]$node
        )

        $Setting = "../.."
        $SettingDiscoveryInfo = ".."
    
        # Grab the ID/Name from the Setting value.
        $ID = $node.SelectNodes($Setting).id.Trim("{").TrimEnd("}")
            
        # Find the ValueData using the ID.
        $valueNodeData = (Select-XML -XPath "//e:SettingRef[@setting_ref='{$($id)}']" -Xml $xml -Namespace $namespace).Node
                        
        if ($valueNodeData -eq $null)
        {
            Write-Error "Could not find ValueNodeData of $id" 
            return $null
        }
        else 
        {
            return $valueNodeData
        }
    }

    Context "Write-XMLRegistryData" {
        
        $SampleREG_DI = $results.Where({$_.DiscoveryType -eq "Registry" -and $_.ChildNodes.name -contains "RegistryDiscoveryInfo"})
        $SampleREG_DI_Alt = $results.Where({$_.DiscoveryType -eq "Registry" -and $_.ChildNodes.name -notcontains "RegistryDiscoveryInfo"})
    
        for ($i = 0; $i -lt $SampleREG_DI.Count;$i++)
        {
            It "Finds RegistyDiscoveryInfo" {
                $SampleREG_DI[$i] | Should Not Be $Null
            }
        
            $SampleREG_VND = Get-ValueNodeData $SampleREG_DI[$i]    

            It "Retrieves Value Node Data" { 
                $SampleREG_VND | Should Not Be $Null
            }

            $Parameters = Write-XMLRegistryData -DiscoveryData $SampleREG_DI[$i] -ValueData $SampleREG_VND
            Write-Host $Parameters.Name

            It "Parses Registry Data" {
                If ($Parameters.CommentOut.IsPresent)
                {
                    Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                }
                else
                {
                    $Parameters.Type | Should Be "Registry"
                    [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should Be $false
                    Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                    $TypeHash = @{"Binary"=[byte];"Dword"=[int];"ExpandString"=[string];"MultiString"=[string];"Qword"=[string];"String"=[string]}
                    ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                    $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                    [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                }
            }

            It "Parses Comment Data" {
                [string]::IsNullOrEmpty($parameters.Comment) | Should Be $false
            }

            It "Converts Comments into StringData" {
                { Get-NodeDataFromComments -Comments $Parameters.Comment } | Should Not Throw
            }
        }

        for ($i = 0; $i -lt $SampleREG_DI_Alt.Count;$i++)
        {
            It "Finds Alternate RegistryDiscoveryInfo" {
                $SampleREG_DI_Alt[$i] | Should Not Be $Null
            }
    
            $SampleREG_VND_Alt = Get-ValueNodeData $SampleREG_DI_Alt[$i]

            It "Retrieves Alternate Value Node Data" { 
                $SampleREG_VND_Alt | Should Not Be $null
            }

            $Parameters_All = Write-XMLRegistryData -DiscoveryData $SampleREG_DI_Alt[$i] -ValueData $SampleREG_VND_Alt

            foreach ($Parameters in  $Parameters_All)
            {
                Write-Host $Parameters.Name

                It "Parses Registry Data" {
                    If ($Parameters.CommentOut.IsPresent)
                    {
                        Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                    }
                    else
                    {
                        $Parameters.Type | Should Be "Registry"
                        [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should Be $false
                        Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                        $TypeHash = @{"Binary"=[byte];"Dword"=[int];"ExpandString"=[string];"MultiString"=[string];"Qword"=[string];"String"=[string]}
                        ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                        $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                        [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                    }
                }

                It "Parses Comment Data" {
                    [string]::IsNullOrEmpty($parameters.Comment) | Should Be $false
                }

                It "Converts Comments into StringData" {
                    { Get-NodeDataFromComments -Comments $Parameters.Comment } | Should Not Throw
                }
            }
        }
    }
        
    Context "Write-XMLAuditData" {
        $SampleAUDIT_DI = $results.Where({$_.DiscoveryType -eq "AdvancedAuditPolicy"})

        for ($i = 0; $i -lt $SampleAUDIT_DI.Count;$i++)
        {
            $SampleAUDIT_VND = Get-ValueNodeData $SampleAUDIT_DI[$i]
            $Parameters = Write-XMLAuditData -DiscoveryData $SampleAUDIT_DI[$i] -ValueData $SampleAUDIT_VND
            Write-Host $Parameters.Name

            It "Parses AUDIT Data" {
                $Parameters.Type | Should BE "xAuditCategory"
                $AuditCategoryHash.Values -contains $Parameters.Parameters.SubCategory | Should Be $true
                @("Failure","NoAuditing","Success","SuccessAndFailure") -contains $Parameters.Parameters.AuditFlag | Should Be $true
                [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
            }

            It "Parses Comment Data" {
                [string]::IsNullOrEmpty($parameters.Comment) | Should Be $false
            }

            It "Converts Comments into StringData" {
                { Get-NodeDataFromComments -Comments $Parameters.Comment } | Should Not Throw
            }
        }
    }

    Context "Write-XMLPrivilegeData" {
        $SamplePRIV_DI = $results.Where({$_.DiscoveryType -eq "GeneratedScript (User Rights Assignment)"})

        for ($i = 0; $i -lt $SamplePRIV_DI.Count;$i++)
        {
            $SamplePRIV_VND = Get-ValueNodeData $SamplePRIV_DI[$i]
            $Parameters = Write-XMLPrivilegeData -DiscoveryData $SamplePRIV_DI[$i] -ValueData $SamplePRIV_VND
            Write-Host $Parameters.Name

            It "Parses PRIVILEGE Data" {
                $Parameters.Type | Should Be "UserRightsAssignment"
                [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                $UserRightsHash.Values -contains $Parameters.Parameters.Policy | Should Be $true
                # Cannot parse Privilege Data without a sample because it COULD actually be Empty
            }

            It "Parses Comment Data" {
                [string]::IsNullOrEmpty($parameters.Comment) | Should Be $false
            }

            It "Converts Comments into StringData" {
                { Get-NodeDataFromComments -Comments $Parameters.Comment } | Should Not Throw
            }
        }
    }

    Context "Write-XMLWMIData" {
        $SampleWMI_DI = $results.Where({$_.DiscoveryType -eq "WMI"})

        for ($i = 0; $i -lt $SampleWMI_DI.Count; $i++)
        {
            $SampleWMI_VND = Get-ValueNodeData $SampleWMI_DI[$i]
            $Parameters = Write-XMLWMIData -DiscoveryData $SampleWMI_DI[$i] -ValueData $SampleWMI_VND
            Write-Host $Parameters.Name

            It "Parses SecuritySetting Data" {
                $Parameters.Type | Should Be "SecuritySetting"
                [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                $SecuritySettings -contains $Parameters.Parameters.Name | Should Be $true
                $Parameters.Parameters.ContainsKey($Parameters.Parameters.Name) | Should Be $true
            }

            It "Parses Comment Data" {
                [string]::IsNullOrEmpty($parameters.Comment) | Should Be $false
            }

            It "Converts Comments into StringData" {
                { Get-NodeDataFromComments -Comments $Parameters.Comment } | Should Not Throw
            }
        }
    }
}

Describe "JSON Conversion Helper Tests" {
    
    $JSON = Get-Content -Path $JSONSample | ConvertFrom-Json
    $registryPolicies = $JSON.properties.RulesetsCollection.BaselineRuleset.rules.BaselineRegistryRule
    $AuditPolicies = $JSON.properties.RulesetsCollection.BaselineRuleset.rules.BaselineAuditPolicyRule
    $securityPolicies = $JSON.properties.RulesetsCollection.BaselineRuleset.rules.BaselineSecurityPolicyRule
    
    Context "Write-JSONRegistryData" {
        Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } -ModuleName HelperFunctions
        
        # Loop through all the registry settings.
        Foreach ($Policy in $registryPolicies)
        {
            $HiveHash = @{"LocalMachine" = "HKLM:"}
            $TypeHash = @{"Int"="DWORD";"String"= "String"}
            $Parameters = Write-JSONRegistryData -RegistryData  $Policy 
            Write-Host $Parameters.Name -ForegroundColor White
            It "Parses Regisry Data" {
                If ($Parameters.CommentOut.IsPresent)
                {
                    Write-Host -ForegroundColor Green "This Resource was commented OUT for failure to adhere to Standards: Tests are Invalid"
                }
                else
                {
                    $Parameters.Type | Should Be "Registry"
                    [string]::IsNullOrEmpty($Parameters.Parameters.ValueName) | Should Be $false
                    Test-Path -Path $Parameters.Parameters.Key -IsValid | Should Be $true
                    $TypeHash = @{"Binary"=[byte];"Dword"=[int];"ExpandString"=[string];"MultiString"=[string];"Qword"=[string];"String"=[string]}
                    ($Parameters.Parameters.ValueType -in @($TypeHash.Keys)) | Should Be $true
                    $Parameters.Parameters.ValueData | Should BeOfType $TypeHash[$Parameters.Parameters.ValueType]
                    [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
                }
            }
            
            switch ($JSON_Entry)
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

                {$_.Enabled -eq $False}
                {
                    It "Respects the Enabled Flag" {
                        $Parameters.CommentOUT | Should Be $true
                    }
                }
            }
        }
    }
    
    Context "Write-JSONAuditData" {
        Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } -ModuleName HelperFunctions
        
        foreach ($Policy in $auditPolicies)
        {
            $Parameters = Write-JSONAuditData -AuditData $Policy 
            Write-Host $Parameters.Name -ForegroundColor White
            It "Parses Audit Data" {
                $Parameters.Type | Should Be xAuditCategory
                $Parameters.Parameters.SubCategory | Should Be $AuditCategoryHash[$Policy.AuditPolicyId]
                $Parameters.Parameters.AuditFlag | Should Be $Policy.ExpectedValue.Trim()
                [string]::IsNullOrEmpty($Parameters.Name) | Should Be $false
            }
        
            if (!$Policy.Enabled)
            {
                It "Respects the Enabled Flag" {
                    $Parameters.CommentOUT | Should Be $True
                }
            }
        }
    }
    
    Context "Write-JSONPrivilegeData" {
        Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } -ModuleName HelperFunctions
        
        foreach ($Policy in $securityPolicies)
        {
            $Parameters = Write-JSONPrivilegeData -PrivilegeData $Policy 
            Write-Host $Parameters.Name
                    
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
                        $Parameters.Parameters.Identity -join ", " | Should Match ((($Policy.ExpectedValue.Replace("No One", "") -split ", ") | %{"(?=.*$_)"}) -join "")
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

             if (!$Policy.Enabled)
             {
                It "Respects the Enabled Flag" {
                    $Parameters.CommentOUT | Should be $true
                }
            }
        }
    }
}