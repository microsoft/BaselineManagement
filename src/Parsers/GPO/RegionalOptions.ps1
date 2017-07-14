#region GPO Parsers
Function Write-GPORegionalOptionsXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )
    $Properties = $XML.Properties
    
    Write-Warning "Write-GPORegionalOptionsXMLData: Setting anything other than localeID is not yet supported"

    if ($Properties.localeID -ne $null)
    {
        $localeHash = @{}
        $localeHash.Name = "UserLocale"
        $localeHash.InputLocaleId = $Properties.localeId
        $localeHash.Ensure = "Present"

        Write-DSCString -Resource -Type rsUserLocale -Name "RegionalOptions(XML): UserLocale" -Parameters $localeHash
    }
}
#endregion