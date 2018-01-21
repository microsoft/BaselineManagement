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
    $ExistensialRule = $valueData.SelectNodes("..").ExistentialRules
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

Function Write-SCMNewSecuritySettingXMLData
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
    $ExistensialRule = $valueData.SelectNodes("..").ExistentialRules
    $ValidationRules = $valueData.SelectNodes("..").ValidationRules
         
    # Grab the Value and Operator
    $TempValue = $ValidationRules.SettingRule.Value.ValueA
    
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

    $ResourceName = $SecuritySetting = ""
    if ($SecurityOptionSettings.ContainsKey($KeyName))
    {
        $SecuritySetting = $SecurityOptionSettings[$keyName]
        $ResourceName = "SecurityOption"
    }
    elseif ($AccountPolicySettings.ContainsKey($KeyName))
    {
        $ResourceName = "AccountPolicy"
        $SecuritySetting = $AccountPolicySettings[$keyName]
    }
    else
    {
        Write-Warning "Write-GPONewSecuritySettingData:$KeyName is no longer supported or is not implemented"
        Add-ProcessingHistory -Type SecurityOption -Name "SecuritySetting(INF): $KeyName" -ParsingError
        return ""
    }

    $parseValue = $TempValue
    if ([bool]::TryParse($parseValue, [ref]$TempValue))
    {
        if ($SecuritySetting -in $SecuritySettingsWEnabledDisabled)
        {
            [string]$TempValue = $EnabledDisabled[[int]$TempValue]
        }
    }
    elseif ([int]::TryParse($parseValue, [ref]$TempValue))
    {
        if ($parseValue -eq -1)
        {
            Write-Warning "Write-GPONewSecuritySettingData:$Name is set to -1 which means 'Not Configured'"
            Add-ProcessingHistory -Type SecurityOption -Name "SecuritySetting(INF): $Name" -Disabled
            return ""
        }
        elseif ($SecuritySetting -in $SecuritySettingsWEnabledDisabled)
        {
            [string]$TempValue = $EnabledDisabled[$TempValue]
        }
    }
    else 
    {
        [string]$TempValue = $parseValue    
    }

    Write-DSCString -Resource -Name $Name -Type $ResourceName -Parameters @{$SecuritySetting = $TempValue; Name = $SecuritySetting} -Comment $Comments
}
