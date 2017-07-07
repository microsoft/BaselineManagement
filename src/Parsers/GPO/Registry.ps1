# Create a variable so we can set DependsOn values between passes.
New-Variable -Name GlobalDependsOn -Value @() -Option AllScope -Scope Script -Force
$GlobalDependsOn = @()
Function Write-GPORegistryXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )
    
    $regHash = @{}
    $regHash.ValueType = "None"
    $regHash.ValueName = ""
    $regHash.ValueData = ""
    $regHash.Key = ""

    $Properties = $XML.Properties

    $ValueData = 1
    if (!([int]::TryParse($Properties.Value, [ref]$ValueData)))
    {
        $ValueData = "'$($Properties.ValueData)'" -replace "[^\u0020-\u007E]", ""
    }

    $regHash.ValueData = $ValueData 
    $regHash.ValueName = $Properties.name -replace "[^\u0020-\u007E]", ""

    switch ($Properties.hive)
    {
        "HKEY_LOCAL_MACHINE" { $regHash.Key = "HKLM:\" }
    }

    $regHash.Key = Join-Path -Path $regHash.Key -ChildPath $Properties.Key

    switch ($Properties.type)
    {
        "REG_SZ" { $reghash.ValueType = "String" }
        "REG_NONE" { $reghash.ValueType = "None" }
        "REG_EXPAND_SZ" { $reghash.ValueType = "ExpandString" }
        "REG_DWORD" { $reghash.ValueType = "DWORD" }
        "REG_QWORD" { $reghash.ValueType = "QWORD" }    
        "REG_BINARY" { $reghash.ValueType = "Binary" }  
        "REG_MULTI_SZ" { $reghash.ValueType = "MultiString" }
        Default { $regHash.ValueType = "None" }
    }

    if ($regHash.ValueType -eq "DWORD" -and ($ValueData -match "(Disabled|Enabled|Not Defined|True|False)" -or $ValueData -eq "''"))
    {
        # This is supposed to be an INT and it's a String
        [int]$regHash.ValueData = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}.$ValueData
    }
    elseif ($regHash.ValueType -eq "String" -or $regHash.ValueType -eq "MultiString")
    {
        [string]$regHash.ValueData = [string]$ValueData
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

    $CommentOUT = $false
    
    Write-DSCString -Resource -Name "XML_$(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
}

Function Write-GPORegistryPOLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [psobject]$Data    
    )

    $regHash = @{}
    $regHash.ValueName = ""
    $regHash.Key = "HKLM:\"

    $regHash.ValueName = $Data.ValueName -replace "[^\u0020-\u007E]", ""
    $regHash.Key = Join-Path -Path $regHash.Key -ChildPath $Data.KeyName
   
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

    # Now setup the rest of the Params Hashtable values.
    $regHash.ValueType = "None"
    $regHash.ValueData = ""

    $ValueData = 1
    if (!([int]::TryParse($Data.ValueData, [ref]$ValueData)))
    {
        $ValueData = "'$($Data.ValueData)'" -replace "[^\u0020-\u007E]", ""
    }

    $regHash.ValueData = $ValueData
    switch ($Data.ValueType)
    {
        "REG_SZ" { $reghash.ValueType = "String" }
        "REG_NONE" { $reghash.ValueType = "None" }
        "REG_EXPAND_SZ" { $reghash.ValueType = "ExpandString" }
        "REG_DWORD" { $reghash.ValueType = "DWORD" }
        "REG_QWORD" { $reghash.ValueType = "QWORD" }    
        "REG_BINARY" { $reghash.ValueType = "Binary" }  
        "REG_MULTI_SZ" { $reghash.ValueType = "MultiString" }
        Default { $regHash.ValueType = "None" }
    }

    if ($regHash.ValueType -eq "DWORD" -and ($ValueData -match "(Disabled|Enabled|Not Defined|True|False)"  -or $ValueData -eq "''"))
    {
        # This is supposed to be an INT and it's a String
        [int]$regHash.ValueData = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}.$ValueData
    }
    elseif ($regHash.ValueType -eq "String"  -or $regHash.ValueType -eq "MultiString")
    {
        [string]$regHash.ValueData = [string]$ValueData
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

    Write-DSCString -Resource -Name (Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName) -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
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

    $values = $ValueData -split ","
            
    $KeyPath = $Key
            
    $ValueName = Split-Path -Leaf $KeyPath
    $regHash.ValueName = $ValueName -replace "[^\u0020-\u007E]", ""
    $regHash.Key = Split-Path -Parent $KeyPath
    $regHash.Key = $regHash.Key -replace "MACHINE\\", "HKLM:\" 
    Try
    {
        $tmpValueData = $values[1..$values.count] -join ","
    }
    Catch 
    {
        $tmpValueData = $null
        $regHash.Remove("ValueData")
        continue    
    }
        
    switch ($values[0]) 
    { 
        "1" 
        { 
            # Not sure what type the legal caption is.  Is it an array of strings?
            if ($regHash.ContainsKey("ValueData"))
            {
                $regHash.ValueData = "'$($tmpValueData)'" -replace "[^\u0020-\u007E]", ""
            }
            $regHash.ValueType = "String"
        } 
                        
        "7" 
        { 
            if ($regHash.ContainsKey("ValueData"))
            {
            $regHash.ValueData = @"
$($tmpValueData)
"@ -replace "[^\u0020-\u007E]", ""
            }
            $regHash.ValueType = "MultiString"
        }
                        
        "4" 
        { 
            if ($regHash.ContainsKey("ValueData"))
            {
                $tstValueData = 1
                if (!([int]::TryParse($tmpValueData, [ref]$tstValueData)))
                {
                    Write-Error "Cannot Parse Value for $ValueData at key $KeyData, setting value to 0"
                    $tmpValueData = 0
                }

                [int]$regHash.ValueData = $tstValueData
            }
            $regHash.ValueType = "DWORD"
        }
                        
        "3" 
        { 
            if ($regHash.ContainsKey("ValueData"))
            {
                $hexified = $tmpValueData -split "," | ForEach-Object { "0x$_"}
            }
            $regHash.ValueData = [byte[]]$hexified
            $regHash.ValueType = "Binary"
        } 

        Default
        {
            Write-Warning "Cannot parse RegistryINF Data"
            Write-Warning "$_"
            return ""
        }
    }
    
    if ($regHash.ValueType -eq "DWORD" -and ($regHash.ValueData -match "(Disabled|Enabled|Not Defined|True|False)" -or $regHash.ValueData -eq "''"))
    {
        # This is supposed to be an INT and it's a String
        [int]$regHash.ValueData = @{"Disabled" = 0; "Enabled" = 1; "Not Defined" = 0; "True" = 1; "False" = 0; '' = 0}.$regHash.ValueData
    }
    elseif ($regHash.ValueType -eq "String" -or $regHash.ValueType -eq "MultiString")
    {
        [string]$regHash.ValueData = [string]$regHash.ValueData
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

    $CommentOUT = $false

    Write-DSCString -Resource -Name "INF_$(Join-Path -Path $regHash.Key -ChildPath $regHash.ValueName)" -Type Registry -Parameters $regHash -CommentOUT:$CommentOUT
}
