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

    $properties = $XML.Properties

    $envHash.Name = $properties.Name
    $envHash.Value = $properties.Value
    $envHash.Path = [bool]$properties.partial
    $envHash.Ensure = switch ($properties.action) { "D" { "Absent" } Default { "Present" } } 


    Write-DSCString -Resource -Name "XML_$($envHash.Name)" -Type Environment -Parameters $envHash
}
#endregion