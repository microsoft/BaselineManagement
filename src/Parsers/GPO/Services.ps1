
Function Write-GPOServicesXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XML    
    )
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
        "3" { $serviceHash.StartupType = "Manual"
              $serviceHash.Remove("State") 
            } 
    }

    # Does the Second (if present) value determine starttype?
    
    Write-DSCString -Resource -Name "INF_$($serviceHash.Name)" -Type Service -Parameters $serviceHash    
}
