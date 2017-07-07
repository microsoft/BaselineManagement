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

$SampleXML = Join-Path -Path $script:SampleRoot -ChildPath "Sample.XML"

Import-Module PSDesiredStateConfiguration -Force

Write-Host "SCM Parser Tests" -ForegroundColor White 

[XML]$XML = Get-Content $SampleXML

# We need to setup a namespace to properly search the XML.
$namespace = @{e = "http://schemas.microsoft.com/SolutionAccelerator/SecurityCompliance"}

# Grab all the DiscoveryInfo objects in the XML. They determine how to find the setting in question.
$results = (Select-XML -XPath "//e:SettingDiscoveryInfo" -Xml $xml -Namespace $namespace).Node

Function Get-ValueNodeData 
{
    param
    (
        [System.Xml.XmlElement]$node
    )

    $Setting = "../.."
    
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

Describe "Write-SCMRegistryXMLData" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    $SampleREG_DI = $results.Where( {$_.DiscoveryType -eq "Registry" -and $_.ChildNodes.name -contains "RegistryDiscoveryInfo"})
    $SampleREG_DI_Alt = $results.Where( {$_.DiscoveryType -eq "Registry" -and $_.ChildNodes.name -notcontains "RegistryDiscoveryInfo"})

    for ($i = 0; $i -lt $SampleREG_DI.Count; $i++)
    {
        It "Finds RegistyDiscoveryInfo" {
            $SampleREG_DI[$i] | Should Not Be $Null
        }
    
        $SampleREG_VND = Get-ValueNodeData $SampleREG_DI[$i]    

        It "Retrieves Value Node Data" { 
            $SampleREG_VND | Should Not Be $Null
        }

        $Parameters = Write-SCMRegistryXMLData -DiscoveryData $SampleREG_DI[$i] -ValueData $SampleREG_VND
        Context $Parameters.Name {
            It "Parses Registry Data" {
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

            It "Parses Comment Data" {
                [string]::IsNullOrEmpty($parameters.Comment) | Should Be $false
            }

            It "Converts Comments into StringData" {
                { Get-NodeDataFromComments -Comments $Parameters.Comment } | Should Not Throw
            }
        }
    }

    for ($i = 0; $i -lt $SampleREG_DI_Alt.Count; $i++)
    {
        It "Finds Alternate RegistryDiscoveryInfo" {
            $SampleREG_DI_Alt[$i] | Should Not Be $Null
        }

        $SampleREG_VND_Alt = Get-ValueNodeData $SampleREG_DI_Alt[$i]

        It "Retrieves Alternate Value Node Data" { 
            $SampleREG_VND_Alt | Should Not Be $null
        }

        $Parameters_All = Write-SCMRegistryXMLData -DiscoveryData $SampleREG_DI_Alt[$i] -ValueData $SampleREG_VND_Alt

        foreach ($Parameters in  $Parameters_All)
        {
            Context $Parameters.Name {
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
                        $TypeHash = @{"Binary" = [byte]; "Dword" = [int]; "ExpandString" = [string]; "MultiString" = [string]; "Qword" = [string]; "String" = [string]}
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
}
    
Describe "Write-SCMAuditXMLData" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    $SampleAUDIT_DI = $results.Where( {$_.DiscoveryType -eq "AdvancedAuditPolicy"})

    for ($i = 0; $i -lt $SampleAUDIT_DI.Count; $i++)
    {
        $SampleAUDIT_VND = Get-ValueNodeData $SampleAUDIT_DI[$i]
        $ValidationRules = $SampleAUDIT_VND.SelectNodes("..").ValidationRules
        $Value = $ValidationRules.SettingRule.Value.ValueA
        $Parameters = Write-SCMAuditXMLData -DiscoveryData $SampleAUDIT_DI[$i] -ValueData $SampleAUDIT_VND
        switch ($Value)
        {
            "Success And Failure"
            {
                It "Parses SuccessAndFailure separately" {
                    $Parameters.Count | Should Be 2
                }
                $Success = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Success"})
                $Failure = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Failure"})
                
                Context $Success.Name {
                    It "Separates out the SuccessBlock" {
                        $Success.Type | Should Be AuditPolicySubcategory
                        $AuditSubCategoryHash.Values -contains $Success.Parameters.Name | Should Be $true
                        $Success.Parameters.AuditFlag | Should Be "Success"
                        $Success.Parameters.Ensure | Should Be "Present"
                        [string]::IsNullOrEmpty($Success.Name) | Should Be $false
                    }

                    It "Parses Comment Data" {
                        [string]::IsNullOrEmpty($Success.Comment) | Should Be $false
                    }

                    It "Converts Comments into StringData" {
                        { Get-NodeDataFromComments -Comments $Success.Comment } | Should Not Throw
                    }
                }

                Context $Failure.Name {
                    It "Separates out the FailureBlock" {
                        $Failure.Type | Should Be AuditPolicySubcategory
                        $AuditSubCategoryHash.Values -contains $Failure.Parameters.Name | Should Be $true
                        $Failure.Parameters.AuditFlag | Should Be "Failure"
                        $Failure.Parameters.Ensure | Should Be "Present"
                        [string]::IsNullOrEmpty($Failure.Name) | Should Be $false
                    }

                    It "Parses Comment Data" {
                        [string]::IsNullOrEmpty($Failure.Comment) | Should Be $false
                    }

                    It "Converts Comments into StringData" {
                        { Get-NodeDataFromComments -Comments $Failure.Comment } | Should Not Throw
                    }
                }
            }

            "No Auditing"
            {
                It "Parses NoAuditing separately" {
                    $Parameters.Count | Should Be 2
                }
                                    
                $Success = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Success"})
                $Failure = $Parameters.Where( {$_.Parameters.AuditFlag -eq "Failure"})
                
                Context $Success.Name {
                    It "Separates out the SuccessBlock" {
                        $Success.Type | Should Be AuditPolicySubcategory
                        $AuditSubCategoryHash.Values -contains $Success.Parameters.Name | Should Be $true
                        $Success.Parameters.AuditFlag | Should Be "Success"
                        $Success.Parameters.Ensure | Should Be "Absent"
                        [string]::IsNullOrEmpty($Success.Name) | Should Be $false
                    }

                    It "Parses Comment Data" {
                        [string]::IsNullOrEmpty($Success.Comment) | Should Be $false
                    }

                    It "Converts Comments into StringData" {
                        { Get-NodeDataFromComments -Comments $Success.Comment } | Should Not Throw
                    }
                }

                Context $Failure.Name {
                    It "Separates out the FailureBlock" {
                        $Failure.Type | Should Be AuditPolicySubcategory
                        $AuditSubCategoryHash.Values -contains $Failure.Parameters.Name | Should Be $true
                        $Failure.Parameters.AuditFlag | Should Be "Failure"
                        $Failure.Parameters.Ensure | Should Be "Absent"
                        [string]::IsNullOrEmpty($Failure.Name) | Should Be $false
                    }

                    It "Parses Comment Data" {
                        [string]::IsNullOrEmpty($Failure.Comment) | Should Be $false
                    }

                    It "Converts Comments into StringData" {
                        { Get-NodeDataFromComments -Comments $Failure.Comment } | Should Not Throw
                    }
                }
            }

            Default
            {
                Context $Parameters.Name {
                    It "Parses Audit Data" {
                        $Parameters.Type | Should BE "AuditPolicySubcategory"
                        $AuditSubCategoryHash.Values -contains $Parameters.Parameters.Name | Should Be $true
                        @("Failure", "Success") -contains $Parameters.Parameters.AuditFlag | Should Be $true
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
        }
    }
}

Describe "Write-SCMPrivilegeXMLData" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    $SamplePRIV_DI = $results.Where( {$_.DiscoveryType -eq "GeneratedScript (User Rights Assignment)"})

    for ($i = 0; $i -lt $SamplePRIV_DI.Count; $i++)
    {
        $SamplePRIV_VND = Get-ValueNodeData $SamplePRIV_DI[$i]
        $Parameters = Write-SCMPrivilegeXMLData -DiscoveryData $SamplePRIV_DI[$i] -ValueData $SamplePRIV_VND
        Context $Parameters.Name {
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
}

Describe "Write-SCMSecuritySettingXMLData" {
    Mock Write-DSCString -Verifiable { return @{} + $___BoundParameters___ } 
    $SampleWMI_DI = $results.Where( {$_.DiscoveryType -eq "WMI"})

    for ($i = 0; $i -lt $SampleWMI_DI.Count; $i++)
    {
        $SampleWMI_VND = Get-ValueNodeData $SampleWMI_DI[$i]
        $Parameters = Write-SCMSecuritySettingXMLData -DiscoveryData $SampleWMI_DI[$i] -ValueData $SampleWMI_VND
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

