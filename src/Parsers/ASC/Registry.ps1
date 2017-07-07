Function Write-ASCRegistryJSONData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $RegistryData
    )

    $ValueData = -1
    switch ($RegistryData.RegValueType)
    {
        "Int" 
        {
            if (!([int]::TryParse($RegistryData.ExpectedValue, [ref]$ValueData)))
            {
                Write-Warning "Could not parse Policy ($($RegistryData.Name)) with ExpectedValue ($($RegistryData.ExpectedValue)) as ($($RegistryData.RegValueType))"
                continue
            }
            else
            {
                $ValueType = "DWORD"
            }
        }

        "String"
        {
            $ValueData = $RegistryData.ExpectedValue.ToString()
            $ValueType = "String"
        }

        "MultipleString"
        {
            $ValueData = $RegistryData.ExpectedValue.ToString()
            $ValueType = "MultiString"
        }
    }

    switch ($RegistryData.Hive)
    {
        "LocalMachine" { $RegistryData.Hive = "HKLM:" }
    }
    
    if ($ValueType -eq "DWORD" -and ($ValueData -match "(Disabled|Enabled|Not Defined|True|False)" -or $ValueData -eq "''"))
    {
        # This is supposed to be an INT and it's a String
        [int]$Value = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}.$Value
    }

    $policyHash = @{}
    $policyHash.Key = $([string]$RegistryData.Hive, [string]$RegistryData.KeyPath -join "\" )
    $policyHash.ValueName = $RegistryData.ValueName
    $policyHash.ValueType = $ValueType
    $policyHash.ValueData = $ValueData
    
    if ($policyHash.ValueType -eq "None")
    {
        # The REG_NONE is not allowed by the Registry resource.
        $policyHash.Remove("ValueType")
    }

    if ([string]::IsNullOrEmpty($policyHash.ValueName))
    {
        $policyHash.Remove("ValueData")
    }

    $commentOUT = $false                
    If ([string]::IsNullOrEmpty($RegistryData.KeyPath))
    {
        $CommentOUT = $true
    }
             
    return Write-DSCString -Resource -Type Registry -Name "$($RegistryData.CCEID): $($RegistryData.ruleName)" -Parameters $policyHash -CommentOUT:($RegistryData.State -ne 'Enabled')
}
