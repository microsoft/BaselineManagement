#region GPO Parsers
Function Write-GPOEnvironmentVariablesXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )

    $envHash = @{}

    $Properties = $XML.Properties

    $envHash.Name = $Properties.Name
    $envHash.Value = $Properties.Value
    $envHash.Path = [bool]$Properties.partial
    $envHash.Ensure = switch ($Properties.action) { "D" { "Absent" } Default { "Present" } } 


    Write-DSCString -Resource -Name "Environment(XML): $($envHash.Name)" -Type Environment -Parameters $envHash
}
#endregion