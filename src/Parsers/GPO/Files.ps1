#region GPO Parsers
Function Write-GPOFilesXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )

    $fileHash = @{}
    $Properties = $XML.properties

    $fileHash.SourcePath = $Properties.fromPath
    $fileHash.DestinationPath = $Properties.targetPath
    $fileHash.Ensure = switch ($Properties.action) { "D" { "Absent" } Default { "Present"} }
    $fileHash.Force = switch ($Properties.action) { "C" { $False } Default { $True } }
    if ($Properties.archive -eq 1 -or $Properties.readonly -eq 1 -or $Properties.hidden -eq 1)
    {
        $fileHash.Attributes = @()
        if ($Properties.archive -eq 1)
        {
            $fileHash.Attributes += "Archive"
        }

        if ($Properties.hidden -eq 1)
        {
            $fileHash.Attributes += "Hidden"
        }

        if ($Properties.readonly -eq 1)
        {
            $fileHash.Attributes += "ReadOnly"
        }
    }

    Write-DSCString -Resource -Name "Files(XML): $($fileHash.DestinationPath)" -Type File -Parameters $fileHash 
}
#endregion