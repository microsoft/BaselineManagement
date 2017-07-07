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