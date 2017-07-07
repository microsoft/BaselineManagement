Import-Module $psScriptRoot\..\..\HelperFunctions.psm1
$type = @"
public enum PRIVILEGES
{
    SeTrustedCredManAccessPrivilege,
    SeTcbPrivilege,
    SeIncreaseQuotaPrivilege,
    SeInteractiveLogonRight,
    SeRemoteInteractiveLogonRight,
    SeBackupPrivilege,
    SeChangeNotifyPrivilege,
    SeSystemtimePrivilege,
    SeTimeZonePrivilege,
    SeCreatePagefilePrivilege,
    SeCreateTokenPrivilege,
    SeCreateGlobalPrivilege,
    SeCreatePermanentPrivilege,
    SeCreateSymbolicLinkPrivilege,
    SeDebugPrivilege,
    SeRemoteShutdownPrivilege,
    SeAuditPrivilege,
    SeImpersonatePrivilege,
    SeIncreaseWorkingSetPrivilege,
    SeIncreaseBasePriorityPrivilege,
    SeLoadDriverPrivilege,
    SeLockMemoryPrivilege,
    SeBatchLogonRight,
    SeSecurityPrivilege,
    SeRelabelPrivilege,
    SeSystemEnvironmentPrivilege,
    SeManageVolumePrivilege,
    SeProfileSingleProcessPrivilege,
    SeSystemProfilePrivilege,
    SeAssignPrimaryTokenPrivilege,
    SeRestorePrivilege,
    SeShutdownPrivilege,
    SeTakeOwnershipPrivilege,
    SeNetworkLogonRight,
    SeDenyNetworkLogonRight,
    SeDenyBatchLogonRight,
    SeDenyServiceLogonRight,
    SeDenyInteractiveLogonRight,
    SeDenyRemoteInteractiveLogonRight,
    SeEnableDelegationPrivilege,
    SeSyncAgentPrivilege,
    SeMachineAccountPrivilege,
}
"@

Add-Type $type -Language CSharp

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("SeTrustedCredManAccessPrivilege", "SeTcbPrivilege", "SeIncreaseQuotaPrivilege", "SeInteractiveLogonRight", "SeRemoteInteractiveLogonRight", "SeBackupPrivilege", "SeChangeNotifyPrivilege", "SeSystemtimePrivilege", "SeTimeZonePrivilege", "SeCreatePagefilePrivilege", "SeCreateTokenPrivilege", "SeCreateGlobalPrivilege", "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeDebugPrivilege", "SeRemoteShutdownPrivilege", "SeAuditPrivilege", "SeImpersonatePrivilege", "SeIncreaseWorkingSetPrivilege", "SeIncreaseBasePriorityPrivilege", "SeLoadDriverPrivilege", "SeLockMemoryPrivilege", "SeBatchLogonRight", "SeSecurityPrivilege", "SeRelabelPrivilege", "SeSystemEnvironmentPrivilege", "SeManageVolumePrivilege", "SeProfileSingleProcessPrivilege", "SeSystemProfilePrivilege", "SeAssignPrimaryTokenPrivilege", "SeRestorePrivilege", "SeShutdownPrivilege", "SeTakeOwnershipPrivilege", "SeNetworkLogonRight", "SeDenyNetworkLogonRight", "SeDenyBatchLogonRight", "SeDenyServiceLogonRight", "SeDenyInteractiveLogonRight", "SeDenyRemoteInteractiveLogonRight", "SeEnableDelegationPrivilege", "SeSyncAgentPrivilege", "SeMachineAccountPrivilege")]
        [string]$Privilege,

        [Parameter()]
        [string[]]$Accounts,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present",

        [Parameter()]
        [bool]$Force=$false
    )
    
    $currUserswithRight = @()
    $currUserswithRight = (Get-AccountsWithUserRight -Right $Privilege -Computer localhost).Account
    $Accounts = @()
    foreach ($user in $currUserswithRight)
    {
        $domain = Split-Path -Path $user -Parent 
        $user = Split-Path -Path $user -Leaf
        
        try 
        {
            if ($domain -eq $env:COMPUTERNAME)
            {
                $objUser = New-Object System.Security.Principal.NTAccount($user)
            }
            else
            {
                $objUser = New-Object System.Security.Principal.NTAccount($domain, $user)
            }
        }
        catch
        {
            continue
        }
        
        if ($objUser)
        {
            $Accounts += $objUser       
        }
    }

    return @{Privilege = $Privilege;Accounts=$Accounts}
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("SeTrustedCredManAccessPrivilege", "SeTcbPrivilege", "SeIncreaseQuotaPrivilege", "SeInteractiveLogonRight", "SeRemoteInteractiveLogonRight", "SeBackupPrivilege", "SeChangeNotifyPrivilege", "SeSystemtimePrivilege", "SeTimeZonePrivilege", "SeCreatePagefilePrivilege", "SeCreateTokenPrivilege", "SeCreateGlobalPrivilege", "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeDebugPrivilege", "SeRemoteShutdownPrivilege", "SeAuditPrivilege", "SeImpersonatePrivilege", "SeIncreaseWorkingSetPrivilege", "SeIncreaseBasePriorityPrivilege", "SeLoadDriverPrivilege", "SeLockMemoryPrivilege", "SeBatchLogonRight", "SeSecurityPrivilege", "SeRelabelPrivilege", "SeSystemEnvironmentPrivilege", "SeManageVolumePrivilege", "SeProfileSingleProcessPrivilege", "SeSystemProfilePrivilege", "SeAssignPrimaryTokenPrivilege", "SeRestorePrivilege", "SeShutdownPrivilege", "SeTakeOwnershipPrivilege", "SeNetworkLogonRight", "SeDenyNetworkLogonRight", "SeDenyBatchLogonRight", "SeDenyServiceLogonRight", "SeDenyInteractiveLogonRight", "SeDenyRemoteInteractiveLogonRight", "SeEnableDelegationPrivilege", "SeSyncAgentPrivilege", "SeMachineAccountPrivilege")]
        [string]$Privilege,

        [Parameter()]
        [string[]]$Accounts,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present",

        [Parameter()]
        [bool]$Force=$false
    )
    
    $currUserswithRight = @()
    $currUserswithRight = (Get-AccountsWithUserRight -Right $Privilege -Computer localhost).Account
    $users = @()
    
    $returnValue = $false
    
    foreach ($Account in $Accounts)
    {
        if ($account -match "\*S")
        {   
            $objSID = New-Object System.Security.Principal.SecurityIdentifier ($SID)
            Try 
            {
                $objUser = $objSID.Translate([System.Security.Principal.NTAccount])

                if ($objUser)
                {
                    $username = $objUser.Value
        
                    if (![string]::IsNullOrEmpty($username))
                    {
                        $users += $username
                    }
                }
            }
            Catch
            {
                continue
            }
        }
        else
        {
            switch ($Account)
            {
                "[Local Account]" { $users += (Get-WmiObject win32_useraccount -Filter "LocalAccount='True'").Caption }
                "[Local Account|Administrator]" 
                {
                   $AdministratorsGroup = Get-WmiObject -class win32_group -filter "SID='S-1-5-32-544'"
                   $GroupUsers = get-wmiobject -query "select * from win32_groupuser where GroupComponent = `"Win32_Group.Domain='$($env:COMPUTERNAME)'`,Name='$($AdministratorsGroup.name)'`""
                   [array]$UsersList = $GroupUsers.partcomponent | %{ (($_ -replace '.*Win32_UserAccount.Domain="', "") -replace '",Name="', "\") -replace '"', '' }
                   $users += $UsersList | ?{$_ -match $env:COMPUTERNAME}
                }
                Default { $users += $Account } 
            }    
        }
    }
    
    if ($Ensure -eq "Present")
    {
        $usersWithoutRight = $users | ?{$_ -notin $currUserswithRight}
        if ($usersWithoutRight)
        {
            Write-Verbose "$($usersWithoutRight -join ",") do not have Privilege ($Privilege)"
            return $false
        }

        if ($Force)
        {
            $effectiveUsers = $currUserswithRight | ?{$_ -notin $users}
            if ($effectiveUsers.Count -gt 0)
            {
                Write-Verbose "$($effectiveUsers -join ",") are extraneous users with Privilege ($Privilege)"
                return $false
            }
        }

        $returnValue = $true
    }
    else
    {
        $UsersWithRight = $users | ?{$_ -in $currUserswithRight}
        if ($UsersWithRight.Count -gt 0)
        {
            Write-Verbose "$($UsersWithRight) should NOT have Privilege ($Privilege)"
            return $false
        }

        $returnValue = $true
    }
    
    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("SeTrustedCredManAccessPrivilege", "SeTcbPrivilege", "SeIncreaseQuotaPrivilege", "SeInteractiveLogonRight", "SeRemoteInteractiveLogonRight", "SeBackupPrivilege", "SeChangeNotifyPrivilege", "SeSystemtimePrivilege", "SeTimeZonePrivilege", "SeCreatePagefilePrivilege", "SeCreateTokenPrivilege", "SeCreateGlobalPrivilege", "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeDebugPrivilege", "SeRemoteShutdownPrivilege", "SeAuditPrivilege", "SeImpersonatePrivilege", "SeIncreaseWorkingSetPrivilege", "SeIncreaseBasePriorityPrivilege", "SeLoadDriverPrivilege", "SeLockMemoryPrivilege", "SeBatchLogonRight", "SeSecurityPrivilege", "SeRelabelPrivilege", "SeSystemEnvironmentPrivilege", "SeManageVolumePrivilege", "SeProfileSingleProcessPrivilege", "SeSystemProfilePrivilege", "SeAssignPrimaryTokenPrivilege", "SeRestorePrivilege", "SeShutdownPrivilege", "SeTakeOwnershipPrivilege", "SeNetworkLogonRight", "SeDenyNetworkLogonRight", "SeDenyBatchLogonRight", "SeDenyServiceLogonRight", "SeDenyInteractiveLogonRight", "SeDenyRemoteInteractiveLogonRight", "SeEnableDelegationPrivilege", "SeSyncAgentPrivilege", "SeMachineAccountPrivilege")]
        [string]$Privilege,

        [Parameter()]
        [string[]]$Accounts,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present",

        [Parameter()]
        [bool]$Force=$false
    )

    $currUserswithRight = @()
    $currUserswithRight = (Get-AccountsWithUserRight -Right $Privilege -Computer localhost).Account
    $users = @()
    
    foreach ($Account in $Accounts)
    {
        if ($account -match "\*S")
        {   
            $objSID = New-Object System.Security.Principal.SecurityIdentifier ($SID)
            Try 
            {
                $objUser = $objSID.Translate([System.Security.Principal.NTAccount])

                if ($objUser)
                {
                    $username = $objUser.Value
        
                    if (![string]::IsNullOrEmpty($username))
                    {
                        $users += $username
                    }
                }
            }
            Catch
            {
                continue
            }
        }
        else
        {
            switch ($Account)
            {
                "[Local Account]" { $users += (Get-WmiObject win32_useraccount -Filter "LocalAccount='True'").Caption }
                "[Local Account|Administrator]" 
                {
                   $AdministratorsGroup = Get-WmiObject -class win32_group -filter "SID='S-1-5-32-544'"
                   $GroupUsers = get-wmiobject -query "select * from win32_groupuser where GroupComponent = `"Win32_Group.Domain='$($env:COMPUTERNAME)'`,Name='$($AdministratorsGroup.name)'`""
                   [array]$UsersList = $GroupUsers.partcomponent | %{ (($_ -replace '.*Win32_UserAccount.Domain="', "") -replace '",Name="', "\") -replace '"', '' }
                   $users += $UsersList | ?{$_ -match $env:COMPUTERNAME}
                }
                Default { $users += $Account } 
            }
        }
    }

    if ($Ensure -eq "Present")
    {
        if ($users.Count -gt 0)
        {
            Write-Verbose "Granting User Rights for $users"
            try
            {
                Grant-UserRight -Account $users -Right $Privilege -Computer localhost
            }
            catch
            {
                Write-Error $_
            }
        }
        else
        {
            Write-Verbose "No users specified to remove Privilege ($Privilege) for with Ensure as Present"
        }

        if ($Force)
        {
            $effectiveUsers = @()
            $effectiveUsers += $currUserswithRight | ?{$_ -notin $users}
            Try
            {
                if ($effectiveUsers.count -gt 0)
                { 
                    Write-Verbose "Revoking Privilege ($Privilege) $($effectiveUsers -join ",") because Ensure was Present"
                    Revoke-UserRight -Account $effectiveUsers -Right $Privilege -Computer localhost
                }
                else
                {
                    Write-Verbose "No users to Revoke Privilege ($Privilege) for in Force Mode with Ensure as Present"
                }
            }
            catch
            {
                Write-Error $_
            }
        }
    }
    else
    {
        try
        {
            if ($users.Count -gt 0)
            {
                Write-Verbose "Revoking Privilege ($Privilege) $($users -join ",") because Ensure was Absent"
                Revoke-UserRight -Account $users -Right $Privilege -Computer localhost
            }
            else
            {
                Write-Verbose "No users to Revoke Privilege ($Privilege) for with Ensure as Absent"
            }                
        }
        catch
        {
            Write-Error $_
        }
    }
}

Export-ModuleMember -Function *-TargetResource;