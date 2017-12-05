Function Write-RegistryCSVData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $RegistryData
    )

    
    $commentOUT = $false  
    switch ($RegistryData.ValueType)
    {
        "REG_DWORD" 
        {
            $ValueType = "DWORD"            
            $ValueData = -1            
            if (!([int]::TryParse($RegistryData.ExpectedValue, [ref]$ValueData)))
            {
                if (($RegistryData.ExpectedValue -match "(Disabled|Enabled|Not Defined|True|False)" -or $RegistryData.ExpectedValue -eq "''"))
                {
                    # This is supposed to be an INT and it's a String
                    [int]$ValueData = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}[$RegistryData.ExpectedValue]
                    $ValueType = "DWORD"            
                }
                else
                {
                    Write-Warning "Could not parse Policy ($($RegistryData.Name)) with ExpectedValue ($($RegistryData.ExpectedValue)) as ($($RegistryData.RegValueType))"
                    $CommentOut = $true
                }
            }
        }

        "REG_SZ"
        {
            $ValueData = $RegistryData.ExpectedValue.ToString()
            $ValueType = "String"
        }

        "REG_MULTI_SZ"
        {
            $ValueData = $RegistryData.ExpectedValue.ToString()
            $ValueType = "MultiString"
        }

        Default 
        {
            $ValueType = $null
        }
    }

    switch ($RegistryData.Hive)
    {
        "LocalMachine" { $RegistryData.Hive = "HKLM:" }
    }

    $policyHash = @{}
    $key, $valuename = [string]$RegistryData.DataSourceKey -split ":"
    if ($valuename -eq $null)
    {
        # Try again without the colon
        $valuename = Split-Path -Path ([string]$RegistryData.DataSourceKey) -Leaf
        $key = Split-Path -Path ([string]$RegistryData.DataSourceKey) -Parent
    }

    $policyHash.Key = $([string]$RegistryData.Hive, [string]$key -join "\" )
    $policyHash.ValueName = $valuename
    if ($ValueType -ne $null)
    {
        $policyHash.ValueType = $ValueType
    }
    
    if ($ValueData)
    {
        $policyHash.ValueData = $ValueData
    }
    
    if ($policyHash.ValueType -eq "None")
    {
        # The REG_NONE is not allowed by the Registry resource.
        $policyHash.Remove("ValueType")
    }

    if ([string]::IsNullOrEmpty($policyHash.ValueName))
    {
        $policyHash.Remove("ValueData")
    }

    if ($RegistryData.ExpectedValue -eq $null)
    {
        $policyHash.Remove("ValueData")
    }
              
    If ([string]::IsNullOrEmpty($PolicyHash.Key))
    {
        $CommentOUT = $true
    }
             
    return Write-DSCString -Resource -Type Registry -Name "$($RegistryData.CCEID): $($RegistryData.Name)" -Parameters $policyHash -CommentOUT:$commentOut -DoubleQuoted
}
