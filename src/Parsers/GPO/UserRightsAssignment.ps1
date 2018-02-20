
Function Write-GPOPrivilegeINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Privilege,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$PrivilegeData
    )

    $privilegeHash = @{}
    $privilegeHash.Policy = ""
    $privilegeHash.Identity = ""
    $privilegeHash.Force = $true

    # These are UserRights
    if ($UserRightsHash.ContainsKey($Privilege))
    {                        
        $privilegeHash.Policy = $UserRightsHash[$Privilege]
    }
    else
    {
        Write-Error "Cannot find $Privilege"
        Add-ProcessingHistory -Type UserRightsAssignment -Name "UserRightsAssignment(INF): $Privilege" -ParsingError
        return ""
    }

    $privilegeHash.Identity = $PrivilegeData -split ","
    
    Write-DSCString -Resource -Name "UserRightsAssignment(INF): $($privilegeHash.Policy)" -Type UserRightsAssignment -Parameters  $privilegeHash
}
