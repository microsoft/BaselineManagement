Function Write-SCMSecuritySettingXMLData
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
    
    $Comments = Get-NodeComments -Node $DiscoveryData
    $Name = $DiscoveryData.SelectNodes("../..").Name
    $Name = "$((Get-NodeDataFromComments -Comments $Comments).'CCEID-50'): $Name"

    # Grab the ExistensialRule and Validation Rule.            
    $ExistensialRule = $valueData.SelectNodes("..").ExistentialRule
    $ValidationRules = $valueData.SelectNodes("..").ValidationRules
       
    $Comments = Get-NodeComments -Node $DiscoveryData
    $Name = $DiscoveryData.SelectNodes("../..").Name
    $Name = "$((Get-NodeDataFromComments -Comments $Comments).'CCEID-50'): $Name"
         
    # Grab the Value and Operator
    $TempValue = $ValidationRules.SettingRule.Value.ValueA
    
    $parseValue = $false
    if ([bool]::TryParse($TempValue, [ref]$parseValue))
    {
        [int]$TempValue = [bool]$parseValue
    }

    $Operator = $ValidationRules.SettingRule.Operator

    $retHash = @{}
    $Where = switch ($DiscoveryData.WMIDiscoveryInfo.Where) { {$_."#text"} {$_."#text"} Default { $_ } }
    $KeyName = ""
    if ($Where -match "KeyName.*'(?<Name>[A-Z]*)'.*")
    {
        $KeyName = $Matches.Name
    }
    else
    {
        Write-Error "Cannot extract Name from $Where"
        return ""
    }
    
    Write-DSCString -Resource -Name $Name -Type SecuritySetting -Parameters @{$KeyName = $TempValue;Name = $KeyName} -Comment $Comments
}
