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
    switch (($PrivilegeData.ExpectedValue -split ",\s*"))
    {
        "No One" { $Accounts = ""; break }
        "0" { $Accounts = ""; break }
        "SERVICE" { $Accounts += "NT AUTHORITY\SERVICE" }
        "NEW_VALUE" { }
        "LOCAL SERVICE" { $Accounts += "NT AUTHORITY\LOCAL SERVICE" }
        "AUTHENTICATED USERS" { $Accounts += "NT AUTHORITY\AUTHENTICATED USERS" }
        "Administrators" { $Accounts += "BUILTIN\Administrators" }
        "NETWORK SERVICE" { $Accounts += "NT AUTHORITY\NETWORK SERVICE" }
        "NT AUTHORITY\Local account and member of Administrators group" { $Accounts += "[Local Account|Administrator]" }
        "NT AUTHORITY\Local account" { $Accounts += "[Local Account]"}
        "Local account" { $Accounts += "[Local Account]"}
        "Guests" { $Accounts += "BUILTIN\Guests"}
        "Backup Operators" { $Accounts += "BUILTIN\Backup Operators"}
        "Server Operators" { $Accounts += "BUILTIN\Server Operators"}
        "NT SERVICE\WdiServiceHost" { $Accounts += "NT SERVICE\WdiServiceHost" }
        "NT VIRTUAL MACHINE\\Virtual Machines" { $Accounts += "NT VIRTUAL MACHINE\Virtual Machines" }
        "Remote Desktop Users" { $Accounts += "BUILTIN\Remote Desktop Users" }
        "Print Operators" { $Accounts += "BUILTIN\Print Operators" }
        "IIS APPPOOL\DefaultAppPool" { $Accounts += "IIS APPPOOL\DefaultAppPool" }
        Default { Write-Warning "Found a new Account Value for JSONPrivilege: $_" }
    }

    $policyHash = @{}
    $policyHash.Force = $true

    $policyHash.Policy = $Privilege
    $policyHash.Identity = $Accounts

    return Write-DSCString -Resource -Name "$($PrivilegeData.CCEID): $($PrivilegeData.ruleName)" -Type UserRightsAssignment -Parameters $policyHash -CommentOUT:($PrivilegeData.State -ne 'Enabled') -DoubleQuoted
}
