Function Write-PrivilegeCSVData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $PrivilegeData
    )

    if ($PrivilegeData.DataSourceKey.TrimStart("{").TrimEnd("}") -match "\[.*\](?<Privilege>.*)")
    {
        $Privilege = $Matches.Privilege
    }
    else
    {
        Write-Error "Cannot Find Privilege!"
        return ""
    }

    if ($UserRightsHash.ContainsKey($Privilege))
    {
        $Privilege = $UserRightsHash[$Privilege]
    }
    else
    {
        Write-Error "Cannot find privilege $($PrivilegeData.DataSourceKey)"
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
        "Local Account" { $Accounts += "[Local Account|Administrator]" }
        "NT AUTHORITY\Local account" { $Accounts += "[Local Account]"}
        "Remote Desktop Users" { $Accounts += "BUILTIN\Remote Desktop Users" }
        "IIS APPPOOL\\DefaultAppPool" { $Accounts += "IIS APPPool\DefaultAppPool" }
        "Guests" { $Accounts += "BUILTIN\Guests"}
        "Backup Operators" { $Accounts += "BUILTIN\Backup Operators"}
        "Server Operators" { $Accounts += "BUILTIN\Server Operators"}
        "ENTERPRISE DOMAIN CONTROLLERS" { $Accounts += "NT AUTHORITY\Enterprise Domain Controllers"}
        "NT Service\WdiServiceHost" { $Accounts += "NT Service\WdiServiceHost"}
        Default { Write-Warning "Found a new Account Value for Privilege: $_" }
    }
                                
    $policyHash = @{}
    if ([string]::IsNullOrEmpty($Accounts))
    {
        $policyHash.Force = $true
    }    
    
    $policyHash.Policy = $Privilege
    $policyHash.Identity = $Accounts                    
                    
    return Write-DSCString -Resource -Name "$($PrivilegeData.CCEID): $($PrivilegeData.Name)" -Type UserRightsAssignment -Parameters $policyHash -DoubleQuoted
}