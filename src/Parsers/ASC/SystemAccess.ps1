Function Write-ASCSystemAccessJSONData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $SystemAccessData
    )

    $SysemAccess = $SystemAccessData.SettingName

    if($SecuritySettings.contains($SysemAccess))
    {

        if ($AccountPolicySettings.ContainsKey($SysemAccess))
        {
            $Type = "AccountPolicy"
            $internalSettingName =  $AccountPolicySettings[$SysemAccess]
        }
        else
        {
            $Type = "SecurityOption"
            $internalSettingName =  $SecurityOptionSettings[$SysemAccess]
        }

        $policyHash = @{}
        $policyHash.Name = $SysemAccess

        $ValueData = $SystemAccessData.ExpectedValue
        if ($internalSettingName -in $SecuritySettingsWEnabledDisabled -and ($ValueData -notmatch "enabled|disabled"))
        {
            [string]$ValueData = $EnabledDisabled[([int]$ValueData)]
        }

        $policyHash.$($internalSettingName) = $ValueData
    }
    else
    {
        Write-Error "Cannot find Account Policy $SysemAccess"
        return ""
    }



    return Write-DSCString -Resource -Name "$($SystemAccessData.CCEID): $($SystemAccessData.ruleName)" -Type $Type -Parameters $policyHash -CommentOUT:($SystemAccessData.State -ne 'Enabled') -DoubleQuoted

}

