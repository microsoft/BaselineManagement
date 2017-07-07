Function Write-SCMRegistryXMLData
{
    [CmdletBinding()]
    [OutputType([string])]
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

    # This means that there is Policy Data
    if ($DiscoveryData.ChildNodes.name -notcontains "RegistryDiscoveryInfo")
    {
        $PolicyData = $DiscoveryData.SelectNodes("../..").Policy
                
        $Hive = switch ($DiscoveryData.Scope) { "Machine" { "HKLM" } }
        
        $Settings = ""
        switch ($PolicyData.Elements)
        {
            {$_.Enum} { $Settings = "Enum"}
            {$_.Boolean} { $Settings = "Boolean" } 
            {$_.Text} { $Settings = "Text" }
            {$_.Decimal} {$Settings = "Decimal" }
            Default { Write-Error "Cannot find Proper Policy Value for $Name"; return "" } 
        }
        
        foreach ($Setting in $PolicyData.Elements."$Settings")
        {
            $retHash = @{}
            $retHash.ValueName = $Setting.ValueName
            $retHash.Key = Join-Path -Path "$($Hive):" -ChildPath $Setting.Key
            
            $value = 1
                        
            [psobject]$TmpValue = ($ValidationRules.OptionRule | Where-Object{$_.Id -eq $Setting.Id}).Value.ValueA
            if ($TmpValue -match '$\(string')
            {
                $TmpValue = $Settings.Item | Where-Object {$_.DisplayName -match $TmpValue}
            }
            
            switch -Regex ($TmpValue)
            {
                {[string]::IsNullOrEmpty($_)} { Write-Error "Cannot Parse Data for $Name"; return ""}
                "(Disabled|Enabled|Not Defined|True|False)" { [int]$TmpValue = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}.$Value; $retHash.ValueType = "DWORD"; break }
                "''" { [int]$TmpValue = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}.$Value; $retHash.ValueType = "DWORD"; break }
                {[int]::TryParse($TmpValue, [ref]$value)} { [int]$TmpValue = $Value; $retHash.ValueType = "DWORD";break}
                Default { [string]$TmpValue = $TmpValue -replace "[^\u0020-\u007E]", ""; $retHash.ValueType = "String"}
            }
            
            $retHash.ValueData = $TmpValue
            
            Write-DSCString -Resource -Name "$($Name): $($setting.Id)" -Type Registry -Parameters $retHash -Comment $Comments
        }
    }
    else
    {
        $retHash = @{}
        $retHash.Key = ""
        $retHash.ValueName = ""
        $retHash.ValueData = ""
        
        # Grab the Value and Operator
        $TempValue = $ValidationRules.SettingRule.Value.ValueA

        if ($DiscoveryData.RegistryDiscoveryInfo.Hive -is [System.XML.XMLElement])
        {
            $Hive = switch ($DiscoveryData.RegistryDiscoveryInfo.Hive."#text") { "HKEY_LOCAL_MACHINE" { "HKLM" } }
            $ValueType = $DiscoveryData.RegistryDiscoveryInfo.DataType."#text"
            $KeyPath = $DiscoveryData.RegistryDiscoveryInfo.KeyPath."#text"
            $ValueName = $DiscoveryData.RegistryDiscoveryInfo.ValueName."#text"
        }
        else
        {
            $Hive = switch ($DiscoveryData.RegistryDiscoveryInfo.Hive) { "HKEY_LOCAL_MACHINE" { "HKLM" } }
            $ValueType = $DiscoveryData.RegistryDiscoveryInfo.DataType
            $KeyPath = $DiscoveryData.RegistryDiscoveryInfo.KeyPath
            $ValueName = $DiscoveryData.RegistryDiscoveryInfo.ValueName
        }

        $retHash.Key = Join-Path -Path "$($Hive):" -ChildPath $KeyPath
        $retHash.ValueName = $ValueName

        $Value = 1
    
        if (!([int]::TryParse($TempValue, [ref]$Value)))
        {
            $Value = "'$($TempValue)'" -replace "[^\u0020-\u007E]", ""
        }
    
        switch ($ValueType)
        {
            "REG_SZ" { $ValueType = "String" }
            "REG_NONE" { $ValueType = "None" }
            "REG_EXPAND_SZ" { $ValueType = "ExpandString" }
            "REG_DWORD" { $ValueType = "DWORD" }
            "REG_QWORD" { $ValueType = "QWORD" }    
            "REG_BINARY" { $ValueType = "Binary" }  
            "REG_MULTI_SZ" { $ValueType = "MultiString" }
            Default { $ValueType = "None" }
        }

        if ($ValueType -eq "DWORD" -and ($Value -match "(Disabled|Enabled|Not Defined|True|False)" -or $ValueData -eq "''"))
        {
            # This is supposed to be an INT and it's a String
            [int]$Value = @{"Disabled"=0;"Enabled"=1;"Not Defined"=0;"True"=1;"False"=0;''=0}.$Value
        }
        elseif ($ValueType -eq "String"  -or $ValueType -eq "MultiString")
        {
            [string]$Value = [string]$Value
        }
                
        $retHash.ValueType = $ValueType
        $retHash.ValueData = $Value
        
        if ($retHash.ValueType -eq "None")
        {
            # The REG_NONE is not allowed by the Registry resource.
            $regHash.Remove("ValueType")
        }

        if ([string]::IsNullOrEmpty($retHash.ValueName))
        {
            $regHash.Remove("ValueData")
        }

        Write-DSCString -Resource -Name $Name -Type Registry -Parameters $retHash -Comment $Comments
    }                
}
