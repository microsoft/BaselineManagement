function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TimeZone,
		[string[]]
		$PeerList
	)

    [string]$CurrentTZ = Invoke-Command {tzutil /g}
    Write-Verbose "Current system time setting is: $CurrentTZ"

    $CurrentPeers = @()
    ((Invoke-Command {w32tm /query /peers}).Split("`n") | Where-Object { $_.contains("Peer:") }) | ForEach-Object {$CurrentPeers += ($_.split()[1])}

    if ($CurrentPeers)
    {    
        Write-Verbose "Current manual peer list setting is: $CurrentPeers"
    }

	$returnValue = @{
		TimeZone = $CurrentTZ
        PeerList = $CurrentPeers
	}
    $returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TimeZone,
		[string[]]
		$PeerList
	)

    try
    {
        $CurrentSetting = (Get-TargetResource -TimeZone $TimeZone -PeerList $PeerList)

        if ($CurrentSetting.TimeZone -ne $TimeZone)
        {
            Write-Verbose "Setting Time Zone to $TimeZone"
            Invoke-Command {tzutil /s $TimeZone}
        }

        if ($PeerList)
        {
            #[array]$PeerList = $PeerList.Split()
            $wmiW32Time = (Get-CimInstance -ClassName win32_service | Where-Object {$_.Name -eq "W32Time"})

            # Check if W32Time service was unregistered, but not stopped
            if (($wmiW32Time.startmode -eq "Disabled") -and ($wmiW32Time.State -eq "Running"))
            {
                Write-Verbose "Windows Time service might have been unregistered, but not stopped... Stopping now..."
                Stop-Service w32time -ErrorAction SilentlyContinue
            }
            
            # Check if w32time service is not registered
            if (-not [bool](Get-Service w32time -ErrorAction SilentlyContinue))
            {
                Write-Verbose "Registering and starting Windows Time service"
                Invoke-Command {w32tm /register}
            }
            
            if ((Get-Service w32time).Status -ne "Running")
            {
                Write-Verbose "Starting Windows Times service"
                Start-Service w32Time
            }
            
            $wmiW32Time = (Get-CimInstance -ClassName win32_service | Where-Object {$_.Name -eq "W32Time"})
            if ($wmiW32Time.Startmode -ne "Auto")
            {
                Set-Service w32Time -StartupType "Automatic"
            }

            # Check if configured peer list matches DSC setting & correct as needed
            if ([bool](Compare-Object $CurrentSetting.PeerList $PeerList))
            {
                Write-Verbose "Configuring Windows Time service"
                Invoke-Command {w32tm /config /manualpeerlist:$PeerList /syncfromflags:manual /update}
            }
        }
        else
        {
            # Unregister w32time service
            if ([bool](Get-Service w32time -ErrorAction SilentlyContinue))
            {
                Write-Verbose "Unregistering Windows Time service"
                Stop-Service w32time
                Invoke-Command {w32tm /unregister}
            }
        }
    }
    catch
    {

    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TimeZone,
		[string[]]
		$PeerList
	)

    try
    {
        $CurrentSetting = (Get-TargetResource -TimeZone $TimeZone -PeerList $PeerList)

        if ($CurrentSetting.TimeZone -eq $TimeZone)
        {
            if ($PeerList)
            {
                # Check if w32time service is registered, running and set to auto-start
                if ([bool](Get-Service w32time -ErrorAction SilentlyContinue))
                {
                    $w32TimeMode = (Get-CimInstance -ClassName win32_service -Property startmode, name | Where-Object {$_.Name -eq "W32Time"} | Select-Object startmode).Startmode
                    if ($w32TimeMode -ne "Auto")
                    {
                        Write-Verbose "W32Time service is not set to Auto-start"
                        return $false
                    }
                    
                    if ((Get-Service w32time).Status -ne "Running")
                    {
                        Write-Verbose "W32Time service is not running"
                        return $false
                    }
                }
                else
                {
                    Write-Verbose "W32Time service is not registered"
                    return $false
                }
                
                if ([bool](Compare-Object $CurrentSetting.PeerList $PeerList.Split() ))
                {
                    Write-Verbose "Current manual peer list does not match DSC settings"
                    return $false
                }
            }
            else
            {
                if ([bool](Get-Service w32time -ErrorAction SilentlyContinue))
                {
                    Write-Verbose "Windows Time service is registered, which does not match current DSC settigns"
                    return $false
                }
            }

            Write-Verbose "Timezone settings are consistent"
            return $true
        }
        else
        {
            Write-Verbose "Timezone settings are not consistent"
            return $false
        }
    }
    catch
    {
        
    }
}

Export-ModuleMember -Function *-TargetResource
