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
    if ($Path -match "(?<Path>%.*%)")
    {
        $Path = [System.Environment]::ExpandEnvironmentVariables($Path)
    }

    $aclHash.Path = $Path

    if ([system.io.path]::HasExtension($Path))
    {
        $aclHash.ObjectType = "File"
    }
    else 
    {
        $aclHash.ObjectType = "Directory"
    }
    
    if ($aclData -match "[0-9],`"(?<DACLString>.*)`"$")
    {
        $aclHash.Sddl = $Matches.DACLString
    }
    else
    {
        Write-Error "Cannot Parse $ACLData for $Path"
        Add-ProcessingHistory -Type cSecurityDescriptorSddl -Name "ACL(INF): $($ACLhash.Path)" -ParsingError
        return ""
    }
    
    Write-DSCString -Resource -Name "ACL(INF): $($ACLhash.Path)" -Type cSecurityDescriptorSddl -Parameters $aclHash
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
    $regHash.SDDL = ""
    $regHash.ObjectType = "RegistryKey"
    
    $regHash.Path = $Path -replace "MACHINE\\", "HKLM:\"
    if ($ACLData -match "[0-9],`"(?<DACLString>.*)`"$")
    {
        $regHash.SDDL = $Matches.DACLString
    }
    else
    {
        Write-Error "Cannot parse $ACLData for $Key"
        Add-ProcessingHistory -Type cSecurityDescriptorSddl -Name "ACL(INF): $($regHash.Path)" -ParsingError
        return ""
    }
    
    Write-DSCString -Resource -Name "ACL(INF): $($regHash.Path)" -Type cSecurityDescriptorSddl -Parameters $regHash
}
