# Create a variable so we can set DependsOn values between passes.
New-Variable -Name GlobalDependsOn -Value @() -Option AllScope -Scope Script -Force
$GlobalDependsOn = @()

Function Resolve-RegistrySpecialCases
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        $regHash
    )

    # Special Cases.
    switch -regex ((Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName))
    {
        "HKLM:\\System\\CurrentControlSet\\Control\\SecurePipeServers\\Winreg\\(AllowedExactPaths|AllowedPaths)\\Machine"
        {
            $regHash.ValueData = $regHash.ValueData -split ","
        }
    }
}

Function Add-RegistryDELVALDependsOn
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $regHash
    )

    $DependsOn = @()
    $delVals = "DELVALS_$($regHash.Key.TrimStart("HKLM:"))"
    if ($script:GlobalDependsOn -contains $delVals -and $ExclusiveFlagAvailable)
    {
        $DependsOn += "[Registry]$delVals"
    }

    $delVal_ValueName = "DEL_$((Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName).TrimStart("HKLM:"))"
    if ($script:GlobalDependsOn -contains $delVal_ValueName)
    {
        $DependsOn += "[Registry]$delVal_ValueName"
    }

    $deleteKeys = "DELETEKEY_$($regHash.Key.TrimStart("HKLM:"))"
    if ($script:GlobalDependsOn -contains $deleteKeys)
    {
        $DependsOn += "[Registry]$deleteKeys"
    }

    $deleteValue = "DELETEVALUES_$((Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName).TrimStart("HKLM:"))"
    if ($script:GlobalDependsOn -contains $deleteValue)
    {
        $DependsOn += "[Registry]$deleteValue"
    }

    if ($DependsOn.count -gt 0)
    {
        $regHash.DependsOn = $DependsOn
    }
}

Function Register-RegistryDELVALDependsOn
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $regHash
    )

    $CommentOUT = $false
    # Process any pol instructions.
    switch -regex ($regHash.ValueName)
    {
        "\*\*del\.(?<ValueName>.*)$" 
        {
            $regHash.ValueName = $Matches.ValueName
            $regHash.Ensure = "Absent"
            $Name = "DEL_$((Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName).TrimStart("HKLM:"))"
            
            $script:GlobalDependsOn += $Name

            # This is only a delete so return from here.
            return Write-DSCString -Resource -Name $Name  -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
        }

        "\*\*delvals\."
        {
            $regHash.Ensure = "Present"
            $regHash.ValueName = ""
            $regHash.Exclusive = $true
            $Name = "DELVALS_$($regHash.Key.TrimStart("HKLM:"))"

            $script:GlobalDependsOn += $Name
            # This is only a delete so return from here.
            return Write-DSCString -Resource -Name $Name  -Type Registry -Parameters $regHash -CommentOUT:(!$ExclusiveFlagAvailable)
        }

        "\*\*DeleteValues"
        {
            $Data.ValueData = $Data.ValueData -replace "[^\u0020-\u007E]", ""
            foreach ($ValueName in ($Data.ValueData -split ";"))
            {          
                $regHash.Ensure = "Absent"
                $Name = "DELETEVALUES_$((Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName).TrimStart("HKLM:"))"

                $script:GlobalDependsOn += $Name

                # This is only a delete so return from here.
                Write-DSCString -Resource -Name $Name  -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
            }

            return
        }

        "\*\*DeleteKeys"
        {
            $Data.ValueData = $Data.ValueData -replace "[^\u0020-\u007E]", ""
            foreach ($Key in ($Data.ValueData -split ";"))
            {          
                $regHash.Ensure = "Absent"
                $Name = "DELETEKEYS_$($regHash.Key.TrimStart("HKLM:"))"

                $script:GlobalDependsOn += $Name

                # This is only a delete so return from here.
                Write-DSCString -Resource -Name $Name  -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
            }

            return
        }

        "\*\*SecureKey"
        {
            $Name = "SECUREKEY_$($regHash.Key)"

            # This is only a delete so return from here.
            return Write-DSCString -Resource -Name $Name  -Type Registry -Parameters $regHash -CommentOUT:$true
        }
    }

    return $null
}

Function Update-RegistryHashtable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $regHash
    )
    
    $regHash.ValueName = $regHash.ValueName -replace "[^\u0020-\u007E]", ""

    if ([string]::IsNullOrEmpty($regHash.ValueName))
    {
        $regHash.Remove("ValueData")
    }
    $typeHash = @{"REG_SZ" = "String"; "REG_NONE" = "None"; "REG_DWORD" = "Dword"; "REG_EXPAND_SZ" = "ExpandString"; "REG_QWORD" = "Qword"; "REG_BINARY" = "Binary"; "REG_MULTI_SZ" = "MultiString"}

    if ($typeHash.ContainsKey($regHash.ValueType))
    {
        $regHash.ValueType = $typeHash[$regHash.ValueType]
    }
    else
    {
        $regHash.ValueType = "None"
    }

    if ($regHash.ContainsKey("ValueData") -and $regHash.ValueData -ne $null)
    {
        switch ($regHash.ValueType)
        {
            "String"
            {
                [string]$regHash.ValueData = "'$($regHash.ValueData)'" -replace "[^\u0020-\u007E]", ""
            }
            
            "None" 
            { 
                $regHash.Remove("ValueData") | Out-Null
            }

            "ExpandString" 
            { 
                # Contains unexpanded Environment Paths. Should I expand them?
                [string]$regHash.ValueData = "'$($regHash.ValueData)'" -replace "[^\u0020-\u007E]", ""
            }
            
            "Dword" 
            { 
                $ValueData = 1
                if ($regHash.ValueData -match "(Disabled|Enabled|Not Defined|True|False)" -or $ValueData -eq "''")
                {
                    # This is supposed to be an INT and it's a String
                    [int]$regHash.ValueData = @{"Disabled" = 0; "Enabled" = 1; "Not Defined" = 0; "True" = 1; "False" = 0; '' = 0}.$ValueData
                }
                elseif (([int]::TryParse($regHash.ValueData, [ref]$ValueData)))
                {
                    [int]$regHash.ValueData = $ValueData
                }
                else
                {
                    # If it doesn't parse as an integer, try parsing as hexadecimal.
                    Try 
                    {
                        if ($regHash.ValueData.StartsWith("0x"))
                        {
                            $regHash.ValueData = "0x$($regHash.ValueData)"
                        }

                        [int]$regHash.ValueData = [Convert]::($regHash.ValueData, 10)
                    }
                    Catch
                    {
                        # Other wise fail over for now until a better option comes along.
                        $regHash.Remove("ValueData") | Out-Null
                    }
                }
            }

            "Qword"
            { 

            }    

            "Binary" 
            { 
                $reghash.ValueType = "Binary" 
                if ($regHash.ContainsKey("ValueData"))
                {
                    if ($regHash.ValueData.Count -gt 1)
                    {
                        Try
                        {
                            [string]$hexified = ($regHash.ValueData | ForEach-Object ToString X2) -join ''
                            [string]$regHash.ValueData = $hexified
                        }
                        Catch
                        {
                            Write-Error "Error Processing Binary Data for Key ($(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName))"
                            $regHash.CommentOut = $true
                            Add-ProcessingHistory -Type Registry -Name "Registry(INF): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -ParsingError
                        }
                    }
                    else
                    {
                        $regHash.ValueData = "$($regHash.ValueData)"
                    }
                }
                
                $regHash.ValueType = "Binary"
            }  

            "MultiString" 
            { 
                # Does this have to be done in the Calling Function instead?
                $regHash.ValueData = @"
$($regHash.ValueData)
"@ -replace "[^\u0020-\u007E]", ""
                
                $reghash.ValueType = "MultiString" 
            }

            Default { $regHash.ValueType = "None" }
        }
    }

    if ($regHash.ValueType -eq "None")
    {
        # The REG_NONE is not allowed by the Registry resource.
        $regHash.Remove("ValueType")
    }

    if ([string]::IsNullOrEmpty($regHash.ValueName))
    {
        $regHash.Remove("ValueData")
    }

    Resolve-RegistrySpecialCases $reghash
}

Function Write-GPORegistryXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )
    
    $regHash = @{}
    $regHash.ValueType = "None"
    $regHash.ValueName = ""
    $regHash.ValueData = ""
    $regHash.Key = ""

    $Properties = $XML.Properties

    $regHash.ValueData = $Properties.Value 
    $regHash.ValueName = $Properties.name
    $regHash.ValueType = $Properties.Type

    $CommentOUT = $false
    switch ($Properties.hive)
    {
        "HKEY_LOCAL_MACHINE" { $regHash.Key = "HKLM:\" }
        "HKEY_CURRENT_USER" 
        { 
            Write-Warning "Write-GPORegistryXMLData: Current User Registry settings are not yet supported."
            $regHash.Key = "HKCU:\"
            $CommentOUT = $true
        }
    }

    $regHash.Key = Join-Path -Path $regHash.Key -ChildPath $Properties.Key

    Update-RegistryHashtable $regHash
        
    Write-DSCString -Resource -Name "Registry(XML): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
}

Function Write-GPORegistryPOLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject]$Data,

        [Parameter()]
        [ValidateSet("HKLM", "HKCU")]
        [string]$Hive = "HKLM"
    )

    $regHash = @{}
    $regHash.ValueName = ""
    $regHash.Key = "$($Hive):\"

    $CommentOUT = $false
    if ($Hive -eq "HKCU")
    {
        Write-Warning "Write-GPORegistryPOLData: CurrentUser settings are currently not supported"
        $CommentOut = $true
    }

    $regHash.ValueName = $Data.ValueName
    $regHash.Key = Join-Path -Path $regHash.Key -ChildPath $Data.KeyName
    $regHash.ValueType = $Data.ValueType.ToString()
    if ($Data.ValueData -eq "$([char]0)")
    {
        $regHash.ValueData = $null
    }
    else
    {
        $regHash.ValueData = $Data.ValueData
    }

    Update-RegistryHashtable $regHash
    
    $output = Register-RegistryDELVALDependsOn $regHash

    if ($output -ne $null)
    {
        return $output
    }
        
    Add-RegistryDELVALDependsOn $regHash

    $comment = ""
    if ($regHash.ValueData -eq $null)
    {
        $Comment = "`tThis MultiString Value has a value of `$null, `n`tSome Security Policies require Registry Values to be `$null`n`tIf you believe ' ' is the correct value for this string, you may change it here."
    }  
    
    Write-DSCString -Resource -Name "Registry(POL): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT -Comment $Comment
}

Function Write-GPORegistryINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ValueData
    )

    $regHash = @{}
    $regHash.ValueType = "None"
    $regHash.ValueName = ""
    $regHash.ValueData = ""
    $regHash.Key = ""

    $CommentOUT = $false

    $values = $ValueData -split ","
            
    $KeyPath = $Key
            
    $ValueName = Split-Path -Leaf $KeyPath
    $regHash.ValueName = $ValueName -replace "[^\u0020-\u007E]", ""
    $regHash.Key = Split-Path -Parent $KeyPath
    $regHash.Key = $regHash.Key -replace "MACHINE\\", "HKLM:\" 
    if (!$regHash.Key.StartsWith("HKLM"))
    {
        Write-Warning "Write-GPORegistryINFData: Current User Registry settings are not yet supported."
        $CommentOUT = $true
    }

    Try
    {
        $regHash.ValueData = $values[1..$values.count]
    }
    Catch 
    {
        $regHash.ValueData = $null
        continue    
    }
    
    $typeHash = @{"1" = "REG_SZ"; "7" = "REG_MULTI_SZ"; "4" = "REG_DWORD"; "3" = "REG_BINARY"}
    if ($typeHash.ContainsKey($values[0]))
    {
        $regHash.ValueType = $typeHash[$values[0]]
    }
    else
    {
        Write-Warning "Write-GPORegistryINFData: $($values[0]) ValueType is not yet supported"
        # Add this resource to the processing history.
        Add-ProcessingHistory -Type Registry -Name "Registry(INF): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -ParsingError
        $CommentOUT = $true
    }
    
    Update-RegistryHashtable $regHash
    if ($regHash.ContainsKey("CommentOut"))
    {
        $CommentOUT = $true
        $regHash.Remove("CommentOut")
    }
    
    Write-DSCString -Resource -Name "Registry(INF): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
}
