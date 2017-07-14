#region GPO Parsers
Function Write-GPOPrintersXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )
    $Properties = $XML.Properties
    
    $printerHash = @{}
    switch -regex ($Properties.LocalName)
    {
        "LocalPrinter"
        {
            $printerHash.Name = $Properties.Name
            $printerHash.DriverName = $Properties.Name
            $printerHash.PortName = $Properties.Port
        }

        "SharedPrinter"
        {
            Write-Warning "Write-GPOPrinterXMLData: Mapping shared printers is not yet supported"
            Add-ProcessingHistory -Type "SharedPrinter" -Name "$($Properties.Path)" -ParsingError
            # Should this be a Script resource?
        }

        "PortPrinter"
        {
            $printerHash.PortName = $Properties.ipAddress
            $printerHash.Name = $Properties.localName
        }

        ".*"
        {
            $printerHash.Location = $Properties.Location
            $printerHash.Comment = $Properties.Comment
        }
    }

    if ($Properties.Default)
    {
        Write-Warning "Write-GPOPrinterXMLData: Setting default printers is not yet supported"
        Add-ProcessingHistory -Type Printer -Name "Printers(XML): $($printerHash.Name)" -ParsingError
    }

    if ($Properties.DeleteAll)
    {
        Write-Warning "Write-GPOPrinterXMLData: Deleting all shared/local printers is not yet supported"
        Add-ProcessingHistory -Type Printer -Name "Printers(XML): $($printerHash.Name)" -ParsingError
    }

    if ($Properties.UserName)
    {
        Write-Warning "Write-GPOPrinterXMLData: Usernames are not yet supported"
        Add-ProcessingHistory -Type Printer -Name "Printers(XML): $($printerHash.Name)" -ParsingError
    }

    if ($Properties.deleteMaps)
    {
        Write-Warning "Write-GPOPrinterXMLData: Deleting all Printer Maps is not yet supported"
        Add-ProcessingHistory -Type Printer -Name "Printers(XML): $($printerHash.Name)" -ParsingError
    }

    $printerHash.Ensure = switch ($Properties.Action) { "D" {"Absent" } Default {"Present"}}
    Write-DSCString -Resource -Type Printer -Name "Printers(XML): $($printerHash.Name)" -Parameters $printerHash
}
#endregion