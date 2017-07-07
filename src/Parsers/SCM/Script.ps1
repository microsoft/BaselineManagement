#region XML Parsers
Function Write-SCMScriptXMLData
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

    $retHash = @{}
    

    return ""
}
#endregion