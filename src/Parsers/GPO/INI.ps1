Function Write-GPOIniFileXMLData
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML  
    )

    $Properties = $XML.Properties
    
    $iniHash = @{}
    $iniHash.Path = $Properties.Path
    switch -regex ($Properties.Action)
    {
        "(C|R|U)"
        {
            $iniHash.Name = $Properties.Property
            $iniHash.Value = $Properties.Value
            $iniHash.Section = $Properties.Section
            $iniHash.Ensure = "Present"
        }

        "(R|U)"
        {
            $iniHash.Force = $true
        }

        "D"
        {
            if ($XML.Property -ne $null)
            {
                $iniHash.Name = $Properties.Property
            }

            if ($XML.Section -ne $null)
            {
                $iniHash.Section = $Properties.Section
            }

            if ($XML.Value -ne $null)
            {
                $iniHash.Value = $Properties.Value
            }

            $iniHash.Ensure = "Absent"
        }

    }

    Write-DSCString -Resource -Type Carbon_IniFile -Name "IniFile(XML): $($iniHash.Path)" -Parameters $iniHash
}