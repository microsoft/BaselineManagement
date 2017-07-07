#region GPO Parsers
Function Write-GPOScheduledTasksXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )

    $schTaskHash = @{}
    $Properties = $XML.Properties
    $schTaskHash.TaskName = $Properties.Name
}
#endregion