
Function Write-GPOSecuritySettingINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$SecurityData
    )
           
    $SecurityData = $SecurityData.Trim()
    $CommentOut = $false
    if ($Key -notin $SecuritySettings)
    {
        Write-Warning "Write-InfSecuritySettingData:$Key is no longer supported or is not implemented"
        Add-ProcessingHistory -Type SecuritySetting -Name "SecuritySetting(INF): $Key" -ParsingError
        return ""
    }

    [int]$ValueData = 1
    if (![int]::TryParse($SecurityData, [ref]$ValueData))
    {
        [string]$ValueData = $SecurityData
    }
    elseif ($ValueData -eq -1)
    {
        Write-Warning "Write-GPONewSecuritySettingData:$Key is set to -1 which means 'Not Configured'"
        Add-ProcessingHistory -Type SecurityOption -Name "SecuritySetting(INF): $Key" -Disabled
        $CommentOut = $true
    }

    $params = @{$key = $ValueData; Name = $Key}
    Write-DSCString -Resource -Name "SecuritySetting(INF): $Key" -Type SecuritySetting -Parameters $params -CommentOut:$CommentOut
}
Function Write-GPONewSecuritySettingINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$SecurityData
    )
           
    $SecurityData = $SecurityData.Trim()
    $ResourceName = $SecuritySetting = ""
    $CommentOut = $false
    if ($SecurityOptionSettings.ContainsKey($Key))
    {
        $SecuritySetting = $SecurityOptionSettings[$key]
        $ResourceName = "SecurityOption"
    }
    elseif ($AccountPolicySettings.ContainsKey($Key))
    {
        $ResourceName = "AccountPolicy"
        $SecuritySetting = $AccountPolicySettings[$key]
    }
    else
    {
        Write-Warning "Write-GPONewSecuritySettingData:$Key is no longer supported or is not implemented"
        Add-ProcessingHistory -Type SecurityOption -Name "SecuritySetting(INF): $Key" -ParsingError
        return ""
    }

    [int]$ValueData = 1
    if (![int]::TryParse($SecurityData, [ref]$ValueData))
    {
        [string]$ValueData = $SecurityData
    }
    elseif ($ValueData -eq -1)
    {
        Write-Warning "Write-GPONewSecuritySettingData:$Key is set to -1 which means 'Not Configured'"
        Add-ProcessingHistory -Type SecurityOption -Name "SecuritySetting(INF): $Key" -Disabled
        $CommentOut = $true
    }
    else
    {
        if ($SecuritySetting -in $SecuritySettingsWEnabledDisabled)
        {
            [string]$ValueData = $EnabledDisabled[$ValueData]
        }
    }

    $params = @{$SecuritySetting = $ValueData;Name = $SecuritySetting}
    Write-DSCString -Resource -Name "SecuritySetting(INF): $Key" -Type $ResourceName -Parameters $params -CommentOut:$CommentOut
}
