#region GPO Parsers
Function Write-GPOGroupsXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )

    $Properties = $XML.Properties

    if (($Properties.removeAllAccounts -ne $Null) -or ($Properties.deleteAllUsers -ne $Null) -or ($Properties.deleteAllGroups -ne $Null))
    {
        Write-Warning "Write-GPOGroupsXMLData: Deleting all users or groups en masse is not supported"
        Add-ProcessingHistory -Type Group -Name "GroupsXML: $($Properties.GroupName)" -ParsingError
    }
    
    $groupHash = @{}
    $groupHash.GroupName = $Properties.GroupName
    if ($XML.groupSid -ne $null)
    {
        $groupHash.GroupName = $Properties.groupSid
    }
    
    $groupHash.Description = $Properties.Description

    $actionHash = @{"ADD" = @(); "REMOVE" = @()}
    $actionHash[$Properties.userAction] += if ($Properties.sid -ne $null) {$Properties.sid} else {$Properties.name}

    if ($Properties.Members -ne $null)
    {
        $members = $Properties.Members.SelectNodes("//Member")
        foreach ($m in $members)
        {
            $actionHash[$m.Action] += if ($m.sid -ne $null) {$m.sid} else {$m.name}
        }
    }

    if ($actionHash["ADD"].Count -gt 0)
    {
        $groupHash.MembersToInclude = $actionHash["ADD"]
    }

    if ($actionHash["REMOVE"].Count -gt 0)
    {
        $groupHash.MembersToInclude = $actionHash["REMOVE"]
    }

    Write-DSCString -Resource -Type Group -Name "Groups(XML): $($groupHash.GroupName)" -Parameters $groupHash
}

Function Write-GroupINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.DictionaryEntry]$GroupData
    ) 
}
#endregion