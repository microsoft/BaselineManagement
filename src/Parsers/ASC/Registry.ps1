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
            If ($RegistryData.analyzeOperation -eq "RANGE")
            {
                $ExpectedValue = $RegistryData.ExpectedValue.Split(',')[-1]
            }
            else
            {
                $ExpectedValue = $RegistryData.ExpectedValue
            }

            if (!([int]::TryParse($ExpectedValue, [ref]$ValueData)))
            {
                Write-Warning "Could not parse Policy ($($RegistryData.Name)) with ExpectedValue ($($ExpectedValue)) as ($($RegistryData.RegValueType))"
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

    if ($policyHash.ValueType -eq "MultiString")
    {
        #$policyHash.ValueData = $policyHash.valuedata -replace "\|#", '"\,\"'
        $policyHash.ValueData = $policyHash.ValueData.Replace('|#|', '|').Split('|')
    }

    return Write-DSCString -Resource -Type Registry -Name "$($RegistryData.CCEID): $($RegistryData.ruleName)" -Parameters $policyHash -CommentOUT:($RegistryData.State -ne 'Enabled') -DoubleQuoted
}
