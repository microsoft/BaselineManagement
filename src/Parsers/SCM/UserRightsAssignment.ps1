Function Write-SCMPrivilegeXMLData
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]   
        [System.Xml.XmlElement]$DiscoveryData,
        
        [Parameter(Mandatory=$true)]   
        [System.Xml.XmlElement]$ValueData
    )
    
    # Grab the ExistensialRule and Validation Rule.            
    $ValidationRules = $valueData.SelectNodes("..").ValidationRules
       
    $Comments = Get-NodeComments -Node $DiscoveryData
    $Name = $DiscoveryData.SelectNodes("../..").Name
    $Name = "$((Get-NodeDataFromComments -Comments $Comments).'CCEID-50'): $Name"
         
    # Grab the Value and Operator
    $TempValue = $ValidationRules.SettingRule.Value.ValueA

    $retHash = @{}
    
    $retHash.Identity = @()
    $retHash.Policy = ""

    if ($DiscoveryData.WmiDiscoveryInfo.Where -match "UserRight='(?<Policy>.*)'.*")
    {
        if ($UserRightsHash.ContainsKey($Matches.Policy))
        {
            $retHash.Policy = $UserRightsHash[$Matches.Policy]
            $retHash.Identity = $TempValue -split ","
        }
        else
        {
            Write-Error "Cannot find matching User Right for Privilege ($($Matches.Privilege))"
            return ""
        }
    }
    else
    {
        Write-Error "Privilege String is not formatted correctly ($($DiscoveryData.WMIDiscoveryInfo.Where))"
        return ""
    }

    Write-DSCString -Resource -Name $Name -Type UserRightsAssignment -Parameters $retHash -Comment $Comments
}
#endregion