function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$DACLString,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter()]
        [bool]$Force=$false
    )
    
    if (Test-Path $Path)
    {
        $container = Split-Path -Path $Path -Parent
        Set-Location $container
        $object = Get-ChildItem -Path $Path

        switch ($object.PSprovider)
        {
            "Registry"
            {
                $Key = Get-ChildItem -Path $Path
                $DACL = Get-Acl -Path $Key.Name
                $directory = Split-Path -Path $filePath -Parent      
        
                $currentDACL = $DACL.GetSecurityDescriptorSddlForm("All")
                return @{Path = $Path;DACLString = $currentDACL}
            }

            "FileSystem"
            {
                $File = Get-ChildItem -Path $Path
                $DACL = Get-Acl -Path $File.FullName
                
                $currentDACL = $DACL.GetSecurityDescriptorSddlForm("All")
                return @{Path = $Path;DACLString = $currentDACL}
            }

            Default { Write-Error "Invalid Provider: $_"; return @{Path=$Path;DACLString=""}}
        } 
    }
    else
    {
        Write-Verbose "$Path does not exist! "
        return @{Path=$Path;DACLString=""}
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$DACLString,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter()]
        [bool]$Force=$false
    )

    $returnValue = $false

    if (Test-Path $Path)
    {
        if ($Force)
        {
            $currDACL = Get-Acl -Path $Path
            $currDACLString = $currDACL.GetSecurityDescriptorSddlForm("All")
                    
            if ($currDACLString -eq $DACLString)
            {
                $returnValue = $true
            }
        }
        else
        {
            $currDACL = Get-Acl -Path $Path
            $currDACLString = $currDACL.GetSecurityDescriptorSddlForm("All")
                    
            # Need a better comparison here!
            if ($currDACLString -match $DACLString)
            {
                $returnValue = $true
            }
        }

        if ($Ensure -eq "Absent")
        {
            $returnValue = !$returnValue
        } 
    }
    else
    {
        Write-Verbose "$Path does not exist! "
        return $returnValue
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$DACLString,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter()]
        [bool]$Force=$false
    )

    if (Test-Path $Path)
    {
        $container = Split-Path -Path $Path -Parent
        Set-Location $container
        $object = Get-ChildItem -Path $Path

        switch ($object.PSprovider)
        {
            "Registry"
            {
                $Key = Get-ChildItem -Path $Path
                if ($Force)
                {
                    if ($Ensure -eq "Absent")
                    {
                        # What do do here?
                    }
                    elseif ($Ensure -eq "Present")
                    {
                        $DACL = New-Object "System.Security.AccessControl.RegistrySecurity"
                        $DACL.SetSecurityDescriptorSddlForm($DACLString)

                        Set-Acl -Path $Path -AclObject $DACL
                    }
                }
                else
                {
                    if ($Ensure -eq "Absent")
                    {
                        # What do do here?
                    }
                    elseif ($Ensure -eq "Present")
                    {
                        # I guess I combine the ACLS??
                    }
                }

                return @{Path = $Path;DACLString = $currentDACL}
            }

            "FileSystem"
            {
                $File = Get-ChildItem -Path $Path
                $DACL = Get-Acl -Path $File.FullName
                
                $currentDACL = $DACL.GetSecurityDescriptorSddlForm("All")
                return @{Path = $Path;DACLString = $currentDACL}
            }

            Default { Write-Error "Invalid Provider: $_"; return @{Path=$Path;DACLString=""}}
        } 
    }
    else
    {
        Write-Verbose "$Path does not exist! "
        return @{Path=$Path;DACLString=""}
    }
}

Export-ModuleMember -Function *-TargetResource;