
Function Write-GPONTServicesXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )

    $serviceHash = @{}
    $Properties = $XML.Properties
    $serviceHash.Name = $Properties.serviceName
    switch ($Properties.ServiceAction)
    {
        "STOP"
        {
            $serviceHash.State = "Stopped"
        }

        "START"
        {
            $serviceHash.State = "Running"
        }

        Default
        {
            Write-Warning "Write-GPONTServicesXMLData:$_ Service Action is not yet supoported."
            Add-ProcessingHistory -Name "Services(XML): $($Properties.serviceName)" -Type Service -ParsingError
        }
    }

    switch -regex ($Properties.startupType)
    {
        "(Automatic|Disabled|Manual)"
        {
            $serviceHash.StartupType = $_
        }
        
        Default
        {
            Write-Warning "Write-GPONTServicesXMLData:$_ StartupType is not yet supoported."
            Add-ProcessingHistory -Name "Services(XML): $($Properties.serviceName)" -Type Service -ParsingError
        }
    }
    
    switch -regex ($Properties.accountName)
    {
        "(LocalService|LocalSystem|NetworkService)"
        {
            $serviceHash.BuiltInAccount = $_
        }

        Default
        {
            Write-Warning "Write-GPONTServicesXMLData: Alternate Credentials ($_) are not yet supoported."
            Add-ProcessingHistory -Name "Services(XML): $($Properties.serviceName)" -Type Service -PasrsingError
        }
    }

    Write-DSCString -Resource -Type Service -Name "NTService: $($serviceHash.Name)" -Parameters $serviceHash
}

Function Write-GPOServiceINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Service,

        [Parameter(Mandatory = $true)]
        [string]$ServiceData
    )

    $serviceHash = @{}
    $serviceHash.Name = ""
    $serviceHash.State = ""

    $values = $ServiceData -split ","
    $serviceHash.Name = $Service
    
    switch ($values[0]) 
    { 
        "2" { $serviceHash.State = "Running" } 
        "4" { $serviceHash.State = "Stopped" } 
        "3"
        {
            $serviceHash.StartupType = "Manual"
            $serviceHash.Remove("State") 
        }
        Default 
        {
            Add-ProcessingHistory -Name "Services(INF): $($serviceHash.Name)" -Type Service -ParsingError
        } 
    }

    # Does the Second (if present) value determine starttype?
    
    Write-DSCString -Resource -Name "Services(INF): $($serviceHash.Name)" -Type Service -Parameters $serviceHash    
}
