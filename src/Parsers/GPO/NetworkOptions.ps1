#region GPO Parsers
Function Write-GPONetworkOptionsXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )
}
#endregion