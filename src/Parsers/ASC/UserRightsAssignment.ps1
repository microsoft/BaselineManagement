Function Write-ASCPrivilegeJSONData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $PrivilegeData
    )

    $Privilege = $PrivilegeData.SettingName
    if ($UserRightsHash.ContainsKey($Privilege))
    {
        $Privilege = $UserRightsHash[$PrivilegeData.SettingName]
    }
    else
    {
        Write-Error "Cannot find privilege $Privilege"
        return ""
    }

    $Accounts = @()
    switch (($PrivilegeData.ExpectedValue -split ", "))
    {
        "No One" { $Accounts = ""; break }
        "SERVICE" { $Accounts += "NT AUTHORITY\SERVICE" } 
        "NEW_VALUE" { }
        "LOCAL SERVICE" { $Accounts += "NT AUTHORITY\LOCAL SERVICE" }
        "AUTHENTICATED USERS" { $Accounts += "NT AUTHORITY\AUTHENTICATED USERS" }
        "Administrators" { $Accounts += "BUILTIN\Administrators" }
        "NETWORK SERVICE" { $Accounts += "NT AUTHORITY\NETWORK SERVICE" }
        "NT AUTHORITY\Local account and member of Administrators group" { $Accounts += "[Local Account|Administrator]" }
        "NT AUTHORITY\Local account" { $Accounts += "[Local Account]"}
        "Guests" { $Accounts += "BUILTIN\Guests"}
        "Backup Operators" { $Accounts += "BUILTIN\Backup Operators"}
        Default { Write-Warning "Found a new Account Value for JSONPrivilege: $_" }
    }
                                
    $policyHash = @{}
    if ([string]::IsNullOrEmpty($Accounts))
    {
        $policyHash.Force = $true
    }    
    
    $policyHash.Policy = $Privilege
    $policyHash.Identity = $Accounts                    
                    
    return Write-DSCString -Resource -Name "$($PrivilegeData.CCEID): $($PrivilegeData.ruleName)" -Type UserRightsAssignment -Parameters $policyHash -CommentOUT:($PrivilegeData.State -ne 'Enabled')
}
