
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

    $regHash = @{}              
    $SecurityData = $SecurityData.Trim()

    if ($Key -notin $SecuritySettings)
    {
        Write-Warning "Write-InfSecuritySettingData:$Key is no longer supported or is not implemented"
        return ""
    }

    [int]$ValueData = 1
    if (![int]::TryParse($SecurityData, [ref]$ValueData))
    {
        [string]$ValueData = $SecurityData
    }

    $params = @{$key = $ValueData;Name = $Key}
    Write-DSCString -Resource -Name "INF_$Key" -Type SecuritySetting -Parameters $params
}
