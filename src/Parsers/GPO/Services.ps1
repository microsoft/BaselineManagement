
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

        {[string]::IsNullOrEmpty($_) -or $_ -eq "NOCHANGE"}
        {

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

        {[string]::IsNullOrEmpty($_) -or $_ -eq "NOCHANGE"}
        {

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

        {[string]::IsNullOrEmpty($_)}
        {

        }

        Default
        {
            Write-Warning "Write-GPONTServicesXMLData: Alternate Credentials ($_) are not yet supoported."
            Add-ProcessingHistory -Name "Services(XML): $($Properties.serviceName)" -Type Service -ParsingError
        }
    }

    if ($Properties.firstFailure -or $Properties.thirdFailure -or $Properties.secondFailure -or $Properties.resetFailCountDelay -or $Properties.restartServiceDelay)
    {
        Write-Warning "Write-GPONTServicesXMLData: Recovery options are only supported by Carbon_Service DSC resource."
        $recoveryAction = @{"START"="RESTART";"STOP"="TAKENOACTION";"RESTART"="Reboot";"NOACTION"="TAKENOACTION";"RESTART_IF_REQUIRED"="RESTART"}
        if ($Properties.firstFailure) { $serviceHash.OnFirstFailure = $recoveryAction[$Properties.firstFailure] }
        if ($Properties.secondFailure) { $serviceHash.OnSecondFailure = $recoveryAction[$Properties.secondFailure] }
        if ($Properties.thirdFailure) { $serviceHash.OnThirdFailure = $recoveryAction[$Properties.thirdFailure] }
        if ($Properties.resetFailCount) { $serviceHash.ResetFailureCount = $Properties.ResetFailureCount }
        if ($Properties.restartServiceDelay) { $serviceHash.RestartDelay = $Properties.restartServiceDelay }
        if ($Properties.program) { $serviceHash.Command = $Properties.program + " " + $Properties.args }
        Write-DSCString -Resource -Type Carbon_Service -Name "(Carbon_Service) NTService: $($serviceHash.Name)" -Parameters $serviceHash
    }
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
