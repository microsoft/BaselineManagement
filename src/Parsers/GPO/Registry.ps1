$ParsersRoot = Get-Item $PsScriptRoot | ForEach-Object {$_.Parent} | ForEach-Object {$_.FullName}
$ModuleRoot = Get-Item $ParsersRoot | ForEach-Object {$_.Parent} | ForEach-Object {$_.FullName}
$Helpers = Join-Path $ModuleRoot 'Helpers'

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
            # $regHash.ValueData = $regHash.ValueData -split ","
        }

        "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\LegalNoticeText"
        {
            #Special case LegalNoticeText, written as a REG_MULTI_SZ by Group Policy Editor but written to registry as REG_SZ
            #Replacing comma with LF (line feed) and CR (Carriage Return)
            $values = $regHash.ValueData -split ","
            $regHash.ValueData = ""
            $values[0..($values.count-2)] | ForEach-Object{$regHash.ValueData += $_ +"`r`n"}
            $regHash.ValueData += $values[($values.count-1)]
            #Change the type to REG_SZ
            $regHash.ValueType = "String"
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
            return Write-DSCString -Resource -Name $Name -Type 'RegistryPolicyFile' -Parameters $regHash -CommentOUT:$CommentOUT
        }

        "\*\*delvals\."
        {
            $regHash.Ensure = "Present"
            $regHash.ValueName = ""
            $regHash.Exclusive = $true
            $Name = "DELVALS_$($regHash.Key.TrimStart("HKLM:"))"

            $script:GlobalDependsOn += $Name
            # This is only a delete so return from here.
            return Write-DSCString -Resource -Name $Name -Type 'RegistryPolicyFile' -Parameters $regHash -CommentOUT:(!$ExclusiveFlagAvailable)
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
                Write-DSCString -Resource -Name $Name -Type 'RegistryPolicyFile' -Parameters $regHash -CommentOUT:$CommentOUT
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
                Write-DSCString -Resource -Name $Name -Type 'RegistryPolicyFile' -Parameters $regHash -CommentOUT:$CommentOUT
            }

            return
        }

        "\*\*SecureKey"
        {
            $Name = "SECUREKEY_$($regHash.Key)"

            # This is only a delete so return from here.
            return Write-DSCString -Resource -Name $Name -Type 'RegistryPolicyFile' -Parameters $regHash -CommentOUT:$true
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

    if ($regHash.ValueType -in $typeHash.Keys)
    {
        $regHash.ValueType = $typeHash[$regHash.ValueType.ToString()]
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
                [string]$regHash.ValueData = "'$($regHash.ValueData)'"# -replace "[^\u0020-\u007E]", ""
            }
            
            "None" 
            { 
                $regHash.Remove("ValueData") | Out-Null
            }

            "ExpandString" 
            { 
                # Contains unexpanded Environment Paths. Should I expand them?
                [string]$regHash.ValueData = "'$($regHash.ValueData)'"# -replace "[^\u0020-\u007E]", ""
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
                        [int]$regHash.ValueData = [Convert]::ToInt32($regHash.ValueData, 16)
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
                            Add-ProcessingHistory -Type 'RegistryPolicyFile' -Name "Registry(INF): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -ParsingError
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
                if ($regHash.ValueData -isnot [System.Array])
                {
                     # Does this have to be done in the Calling Function instead?
                    $regHash.ValueData = @"
$($regHash.ValueData)
"@# -replace "[^\u0020-\u007E]", ""
               
                }

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
    
    # TODO this likely will need additional types in the future
    $regHash.TargetType = 'ComputerConfiguration'

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
    
    Write-DSCString -Resource -Name "Registry(POL): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type 'RegistryPolicyFile' -Parameters $regHash -CommentOUT:$CommentOUT -Comment $Comment
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

    # Loading SecurityOptionData
    $securityOptionData = Import-PowerShellDataFile (Join-Path $Helpers 'SecurityOptionData.psd1')
    $securityOption = $securityOptionData.GetEnumerator() | Where-Object {$_.Value.Value -eq $Key}
    $Name = $securityOption.Name
    if ($null -eq $Name) {
        throw "The GptTmpl.inf file contains an entry '$Key' in the Registry section that is an unknown value in the module file Helpers\SecurityOptionData.psd1."
    }

    $regHash = @{}
    $regHash.ValueType = "None"
    $regHash.ValueName = ""
    $regHash.ValueData = ""
    $regHash.Key = ""
    # TODO this likely will need additional types in the future
    $regHash.TargetType = 'ComputerConfiguration'

    $CommentOUT = $false

    Try
    {
        if ($ValueData -match "^(\d),")
        {
            $valueType = $Matches.1
            $values = ($ValueData -split "^\d,")[1]
            $values = $values -replace '","', '&,'
            $values = $values -split '(?=[^&]),'
            for ($i = 0; $i -lt $values.count;$i++)
            {
                $values[$i] = $values[$i] -replace '&,', ","
            }

            $regHash.ValueData = $values
        }
        else
        {
            throw "Malformed data"
        }
    }
    catch
    {
        $regHash.ValueData = $null
        continue    
    }
            
    $regHash.ValueName = $Name
    $regHash.Key = $Key
    if (!$regHash.Key.StartsWith("MACHINE"))
    {
        Write-Warning "Write-GPORegistryINFData: Current User Registry settings are not yet supported."
        $CommentOUT = $true
    }

    $typeHash = @{"1" = "REG_SZ"; "7" = "REG_MULTI_SZ"; "4" = "REG_DWORD"; "3" = "REG_BINARY"}
    if ($typeHash.ContainsKey($valueType))
    {
        $regHash.ValueType = $typeHash[$valueType]
    }
    else
    {
        Write-Warning "Write-GPORegistryINFData: $($values[0]) ValueType is not yet supported"
        # Add this resource to the processing history.
        Add-ProcessingHistory -Type 'SecurityOption' -Name "Security(INF): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -ParsingError
        $CommentOUT = $true
    }
    
    Write-DSCString -Resource -Name "Security(INF): $(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type 'Security' -Parameters $regHash -CommentOUT:$CommentOUT
}
