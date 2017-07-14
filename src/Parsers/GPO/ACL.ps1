Function Write-GPOFileSecurityINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ACLData
    )

    $aclHash = @{}
    $aclHash.Path = ""
    $aclHash.DACLString = ""

    # These are DACLS                       
    $aclHash.Path = ((($Path -replace "^%", "`env:") -replace "%\\", "\") -replace "%", "")
    if ($aclData -match "[0-9],(.*)$")
    {
        $aclHash.DACLString = $Matches[1]
    }
    else
    {
        Write-Error "Cannot Parse $ACLData for $Path"
        Add-ProcessingHistory -Type ACL -Name "ACL(INF): $($ACLhash.Path)" -ParsingError
        return ""
    }
    
    Write-DSCString -Resource -Name "ACL(INF): $($ACLhash.Path)" -Type ACL -Parameters $aclHash
}

Function Write-GPORegistryACLINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$ACLData
    )

    $regHash = @{}
    $regHash.Path = ""
    $regHash.DACLString = ""
                   
    $regHash.Path = $Path -replace "MACHINE\\", "HKLM:\"
    if ($ACLData -match "[0-9],(.*)$")
    {
        $regHash.DACLString = $Matches[1]
    }
    else
    {
        Write-Error "Cannot parse $ACLData for $Key"
        Add-ProcessingHistory -Type ACL -Name "ACL(INF): $($regHash.Path)" -ParsingError
        return ""
    }
    
    Write-DSCString -Resource -Name "ACL(INF): $($regHash.Path)" -Type ACL -Parameters $regHash
}
