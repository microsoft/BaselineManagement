#region GPO Parsers
Function Write-GPONetworkSharesXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )

    $smbHash = @{}
    $Properties = $XML.Properties
    $smbHash.Name = $Properties.Name
    $smbHash.Path = $Properties.Path
    if ($Properties.limitUsers -eq "SET_LIMIT") 
    {
        $smbHash.ConcurrentUsers = $Properties.userLimit
    }

    if ($Properties.abe -match "(ENABLE|DISABLE)")
    {
        $smbHash.FolderEnumerationMode = @{"ENABLE"="AccessBased";"DISABLE"="Unrestricted"}[$Properties.abe]
    }

    $smbHash.Ensure = switch ($properties.action) { "D" { "Absent" } Default { "Present" } }
    
    Write-DSCString -Resource -Type SmbShare -Name "XML_$($smbHash.Name)" -Parameters $smbHash 
}
#endregion