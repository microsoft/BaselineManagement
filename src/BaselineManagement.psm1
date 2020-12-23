$Helpers = "$PsScriptRoot\Helpers\"
$Parsers = "$PsScriptRoot\Parsers\"

Get-ChildItem -Path $Helpers -Recurse -Filter '*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $Parsers -Recurse -Filter '*.ps1' | ForEach-Object { . $_.FullName }

<#
.Synopsis
   This cmdlet converts Backed Up GPOs into DSC Configuration Scripts.
.DESCRIPTION
   This cmdlet will take the exported GPO and convert all internal settings into DSC Configurations.
.EXAMPLE
   Backup-GPO <GPO Name> | ConvertFrom-GPO
.EXAMPLE
   dir .\<GPO GUID> | ConvertFrom-GPO
.INPUTS
   The GPO Object or directory.
.OUTPUTS
   This script will output a localhost.mof if successful and a failed Configuration Script file if failed.  It will also, on request, output the Configuration Script PS1 file.
#>
function ConvertFrom-GPO
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        # This is the Path of the GPO Backup Directory.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Path")]
        [String]$Path,

        # Output Path that will default to an Output directory under the current Path.
        [string]$OutputPath = $(Join-Path $pwd.Path "Output"),

        # ComputerName for Node processing.
        [string]$ComputerName = "localhost",

        # This determines whether or not to output a ConfigurationScript in addition to the localhost.mof
        [switch]$OutputConfigurationScript,

        # Output results of parsing activities 
        [switch]$ShowPesterOutput,

        # Specifies the name of the Configuration to create
        [string]$ConfigName = 'DSCFromGPO',

        # Return file system details rather than object
        [switch]$PassThru
    )

    Begin
    {
        # These are the DSC Resources needed for NON-preference based GPOS.
        $NeededModules = 'GPRegistryPolicyDsc', 'AuditPolicyDSC', 'SecurityPolicyDSC'

        # Start tracking Processing History.
        Clear-ProcessingHistory

        # Create the Configuration String
        $ConfigString = Write-DSCString -Configuration -Name $ConfigName
        # Add required modules
        Write-Warning "CALL Write-DSCString: $NeededModules"
        $ConfigString += Write-DSCString -ModuleImport -ModuleName $NeededModules
        # Add node data
        $configString += Write-DSCString -Node -Name $ComputerName
    }

    Process
    {
        $resolvedPath = $null
        Try
        {
            $resolvedPath = $Path | Get-Item
        }
        Catch
        {
            Write-Error $_
            return
        }

        Write-Host "Gathering GPO Data from $resolvedPath"

        $polFiles = Get-ChildItem -Path $Path -Filter registry.pol -Recurse

        $AuditCSVs = Get-ChildItem -Path $Path -Filter Audit.csv -Recurse

        $GPTemplateINFs = Get-ChildItem -Path $Path -Filter GptTmpl.inf -Recurse

        <#
        Preferences not supported in current version

        $PreferencesDirectory = Get-ChildItem -Path $Path -Directory -Filter "Preferences" -Recurse

        $AddingModules = @()
        if ($PreferencesDirectory -ne $null)
        {
            $PreferencesXMLs = Get-ChildItem -Path $PreferencesDirectory.FullName -Filter *.xml -Recurse

            if ($PreferencesXMLs -ne $null)
            {
                # These are the Preference Based DSC Resources.
                $AddingModules = 'xSMBShare', 'DSCR_PowerPlan', 'xScheduledTask', 'Carbon', 'PrinterManagement', 'rsInternationalSettings'
            }
        }

        if ($AddingModules.Count -gt 0 -and $AddedModules -eq $false)
        {
            $AddingModulesString = Write-DSCString -ModuleImport -ModuleName $AddingModules -AddingModules
            $ConfigString = $ConfigString.Insert($ConfigString.IndexOf("Node") - 2, "`n`t" + $AddingModulesString)
            $AddedModules = $true
        }
        #>

        # This section collects content from (Registry) POL files
        foreach ($polFile in $polFiles)
        {
            if ((Get-Command "Read-PolFile" -ErrorAction SilentlyContinue) -ne $null)
            {
                # Reaad each POL file found.
                Write-Verbose "Reading Pol File ($($polFile.FullName))"
                Try
                {
                    $registryPolicies = Read-PolFile -Path $polFile.FullName
                }
                Catch
                {
                    Write-Error $_
                }
            }
            elseif ((Get-Command "Parse-PolFile" -ErrorAction SilentlyContinue) -ne $null)
            {
                # Read each POL file found.
                Write-Verbose "Reading Pol File ($($polFile.FullName))"
                Try
                {
                    $registryPolicies = Parse-PolFile -Path $polFile.FullName
                }
                catch
                {
                    Write-Error $_
                }
            }
            else
            {
                Write-Error "Cannot Parse Pol files! Please download and install GPRegistryPolicyParser from github here: https://github.com/PowerShell/GPRegistryPolicyParser"
                break
            }

            # Loop through every policy in the Pol File.
            Foreach ($Policy in $registryPolicies)
            {
                $Hive = @{User = "HKCU"; Machine = "HKLM"}

                # Convert each Policy Registry object into a Resource Block and add it to our Configuration string.
                $ConfigString += Write-GPORegistryPOLData -Data $Policy -Hive $Hive[$polFile.Directory.BaseName]
            }
        }

        # This section collects content from (Audit) CSV files
        foreach ($AuditCSV in $AuditCSVs)
        {
            $otherSettingsCSV = @()
            foreach ($CSV in (Import-CSV -Path $AuditCSV.FullName))
            {
                switch ($CSV)
                {
                    {$_.Subcategory -match "GlobalSacl"}
                    {
                        $otherSettingsCSV += $CSV
                        break
                    }

                    {!([string]::IsNullOrEmpty($_.'Subcategory GUID'))}
                    {
                        $ConfigString += Write-GPOAuditCSVData -Entry $CSV
                        break
                    }

                    {$_.Subcategory -match "^Option"}
                    {
                        $ConfigString += Write-GPOAuditOptionCSVData -Entry $CSV
                        break
                    }
                    Default
                    {
                        Write-Warning  "ConvertFrom-GPO: $($CSV.SubCategory) is not currently supported"
                    }
                }
            }

            <#
            Still trying to figure out how to handle Resource SACLS

            if ($othersettingsCSV.count -gt 0)
            {
                $contents = ""
                for ($i = 0; $i -lt $othersettingsCSV.Count; $i++)
                {
                    $setting = $othersettingsCSV[$i]
                    $contents += "$($setting.'Machine Name'),$($setting.'Policy Target'),$($setting.Subcategory),$($setting.'Subcategory GUID'),$($setting.'Inclusion Setting'),$($setting.'Exclusion Setting'),$($setting.'Setting Value')"
                    if (($i + 1) -lt $othersettingsCSV.Count)
                    {
                        $contents += ","
                    }
                    $contents += "`n"
                }

                $tempCSVPath = "C:\windows\temp\polaudit.csv"
                $ConfigString += Write-DscString -Resource -Name "OtherAuditSettingsCSV" -Type File -Parameters @{DestinationPath=$tempCSVPath;Force=$true;Contents=$contents}
                $ConfigString += Write-DscString -Resource -Name "AuditPolicyDSC: Other Audit Settings" -Type AuditPolicyCSV -Parameters @{IsSingleInstance = "Yes"; CsvPath = $tempCSVPath; DependsOn = "[File]OtherAuditSettingsCSV"}
            }
            #>
        }

        # This section collects content from (Secutiy) INF files
        foreach ($GPTemplateINF in $GPTemplateINFs)
        {
            Write-Verbose "Reading GPTmp.inf ($($GPTemplateINF.FullName))"
            # GPTemp files are in INI format so this function converts it to a hashtable.
            $ini = Get-IniContent $GPTemplateINF.fullname

            # Loop through every heading.
            foreach ($key in $ini.Keys)
            {
                # Loop through every setting in the heading.
                foreach ($subKey in $ini[$key].Keys)
                {
                    switch -regex ($key)
                    {
                        "Service General Setting"
                        {
                            $ConfigString += Write-GPOServiceINFData -Service $subkey -ServiceData $ini[$key][$subKey]
                        }

                        "Registry Values"
                        {
                            $ConfigString += Write-GPORegistryINFData -Key $subkey -ValueData $ini[$key][$subKey]
                        }

                        "File Security"
                        {
                            $ConfigString += Write-GPOFileSecurityINFData -Path $subkey -ACLData $ini[$key][$subKey]
                        }

                        "Privilege Rights"
                        {
                            $ConfigString += Write-GPOPrivilegeINFData -Privilege $subkey -PrivilegeData $ini[$key][$subKey]
                        }

                        "Kerberos Policy"
                        {
                            if ($GlobalConflictEngine.ContainsKey("SecurityOption"))
                            {
                                $ConfigString += Write-GPONewSecuritySettingINFData -Key $subKey -SecurityData $ini[$key][$subkey]
                            }
                            else
                            {
                                $ConfigString += Write-GPOSecuritySettingINFData -Key $subKey -SecurityData $ini[$key][$subkey]
                            }
                        }

                        "Registry Keys"
                        {
                            #TODO
                            $ConfigString += Write-GPORegistryACLINFData -Path $subkey -ACLData $ini[$key][$subKey]
                        }

                        "System Access"
                        {
                            if ($GlobalConflictEngine.ContainsKey("SecurityOption"))
                            {
                                $ConfigString += Write-GPONewSecuritySettingINFData -Key $subKey -SecurityData $ini[$key][$subkey]
                            }
                            else
                            {
                                $ConfigString += Write-GPOSecuritySettingINFData -Key $subKey -SecurityData $ini[$key][$subkey]
                            }
                        }

                        "Event Audit"
                        {
                            $ConfigString += Write-GPOAuditINFData -Key $subKey -AuditData $ini[$key][$subkey]
                        }

                        "(Version|signature|Unicode|Group Membership)"
                        {
                            #TODO
                        }

                        Default
                        {
                            Write-Warning "ConvertFrom-GPO:GPTemp.inf $key AND $subkey heading not yet supported"
                        }
                    }
                }
            }

            # This has to be done separately because it can cause resource conflicts.
            if ($ini.ContainsKey("Group MemberShip"))
            {
                $groupMembership = @{}
                foreach ($KeyPair in $ini["Group Membership"].GetEnumerator())
                {
                    $groupName, $Property = $KeyPair.Name -split "__"
                    $GroupData = @()
                    if (![String]::IsNullOrEmpty($KeyPair.Value))
                    {
                        $GroupData = @(($KeyPair.Value -split "," | ForEach-Object { "$_" }) -join ",")
                    }

                    switch ($Property)
                    {
                        "Members"
                        {
                            if ($groupMembership.ContainsKey($groupName))
                            {
                                $groupMembership[$groupName].Members += $GroupData
                            }
                            else
                            {
                                $groupMembership[$groupName] = @{}
                                $groupMembership[$groupName].GroupName = $groupName
                                $groupMembership[$groupName].Members = $GroupData
                            }
                        }

                        "MemberOf"
                        {
                            if ($GroupData.Count -gt 0)
                            {
                                foreach ($Group in $GroupData)
                                {
                                    if ($groupMembership.ContainsKey($Group))
                                    {
                                        $groupMembership[$group].MembersToInclude += $GroupData
                                    }
                                    else
                                    {
                                        $groupMembership[$group] = @{}
                                        $groupMembership[$group].GroupName = $Group
                                        $groupMembership[$group].MembersToInclude = $GroupData
                                    }
                                }
                            }
                        }

                        Default
                        {
                            Write-Warning "Group Membership: $Property is not a valid Property"
                            continue
                        }
                    }
                }

                foreach ($Key in $GroupMembership.Keys)
                {
                    $CommentOut = $false
                    $configString += Write-DSCString -Resource -Name $Key -Parameters $GroupMemberShip[$key] -Type Group -CommentOut:$CommentOut
                }
            }
        }

        # There is also SOMETIMES a RegistryXML file that contains some additional registry information.
        foreach ($XML in $PreferencesXMLs)
        {
            Write-Verbose "Reading $($XML.BaseName)XML ($($XML.FullName))"

            # Grab the XML info.
            [xml]$XMLContent = Get-Content $XML.FullName

            switch ($XML.BaseName)
            {
                "Files"
                {
                    $Settings = (Select-Xml -XPath "//$_/File" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOFilesXMLData -XML $Setting
                    }
                }

                "Folders"
                {
                    $Settings = (Select-Xml -XPath "//$_/Folder" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOFoldersXMLData -XML $Setting
                    }
                }

                "EnvironmentVariables"
                {
                    $Settings = (Select-Xml -XPath "//$_/EnvironmentVariable" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOEnvironmentVariablesXMLData -XML $Setting
                    }
                }

                "Groups"
                {
                    $Settings = (Select-Xml -XPath "//Group" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOGroupsXMLData -XML $Setting
                    }
                }

                "IniFiles"
                {
                    $Settings = (Select-Xml -XPath "//$_" -Xml $XMLContent).Node
                    foreach ($setting in $settings)
                    {
                        $ConfigString += Write-GPOIniFileXMLData -XML $Setting
                    }
                }

                "InternetSettings"
                {
                    $Settings = (Select-Xml -XPath "//Reg" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOInternetSettingsXMLData -XML $Setting
                    }
                }

                "NetworkOptions"
                {
                    <#$Settings = (Select-Xml -XPath "//$_" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPONetworkOptionsXMLData -XML $Setting
                    }#>
                    Write-Warning "ConvertFrom-GPO:$($XML.BaseName) XML file is not implemented yet."
                }

                "NetworkShareSettings"
                {
                    $Settings = (Select-Xml -XPath "//$_/NetShare" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPONetworkSharesXMLData -XML $Setting
                    }
                }

                "PowerOptions"
                {
                    $GlobalPowerOptions = (Select-Xml -XPath "//$_/GlobalPowerOptions" -xml $XMLContent).Node
                    $PowerPlans = (Select-Xml -XPath "//$_/GlobalPowerOptionsV2" -xml $XMLContent).Node
                    $PowerSchemes = (Select-Xml -XPath "//$_/PowerScheme" -xml $XMLContent).Node

                    foreach ($PowerOption in $GlobalPowerOptions)
                    {
                        $ConfigString += Write-GPOGlobalPowerOptionsXMLData -XML $PowerOption
                    }

                    foreach ($PowerPlan in $PowerPlans)
                    {
                        $ConfigString += Write-GPOPowerPlanXMLData -XML $PowerPlan
                    }

                    foreach ($PowerScheme in $PowerSchemes)
                    {
                        $ConfigString += Write-GPOPowerSchemeXMLData -XML $PowerScheme
                    }

                    Write-Warning "ConvertFrom-GPO:$($XML.BaseName) XML file is not implemented yet."
                }

                "Printers"
                {
                    $Settings = (Select-Xml -XPath "//Printers" -xml $XMLContent).Node

                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOPrintersXMLData -XML $Setting
                    }
                }

                "RegionalOptions"
                {
                    $Settings = (Select-Xml -XPath "//Regional" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPORegionalOptionsXMLData -XML $Setting
                    }
                }

                "Registry"
                {
                    $Settings = (Select-Xml -XPath "//$_" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPORegistryXMLData -XML $Setting
                    }
                }

                "Services"
                {
                    $Settings = (Select-Xml -XPath "//NTService" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPONTServicesXMLData -XML $Setting
                    }
                }

                "Shortcuts"
                {
                    <#$Settings = (Select-Xml -XPath "//$_" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOShortcutsXMLData -XML $Setting
                    }#>
                    Write-Warning "ConvertFrom-GPO:$($XML.BaseName) XML file is not implemented yet."
                }

                "StartMenu"
                {
                    <#$Settings = (Select-Xml -XPath "//$_" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOStartMenuXMLData -XML $Setting
                    }#>
                    Write-Warning "ConvertFrom-GPO:$($XML.BaseName) XML file is not implemented yet."
                }

                "ScheduledTasks"
                {
                    $Settings = (Select-Xml -XPath "//ScheduledTasks/*" -xml $XMLContent).Node

                    # Loop through every registry setting.
                    foreach ($Setting in $Settings)
                    {
                        $ConfigString += Write-GPOScheduledTasksXMLData -XML $Setting
                    }
                }

                Default
                {
                    Write-Warning "ConvertFrom-GPO:$($XML.BaseName) XML file is not implemented yet."
                }
            }
        }
    }

    end
    {
        # Close out the Node Block and the configuration.
        $ConfigString += Write-DSCString -CloseNodeBlock
        $ConfigString += Write-DSCString -CloseConfigurationBlock
        $ConfigString += Write-DSCString -InvokeConfiguration -Name $ConfigName -OutputPath $OutputPath

        if (!(Test-Path $OutputPath))
        {
            mkdir $OutputPath
        }

        # If the switch was specified, output a Configuration PS1 regardless of success or failure.
        if ($OutputConfigurationScript)
        {
            $Scriptpath = Join-Path $OutputPath "$ConfigName.ps1"
            Write-Verbose "Outputting Configuration Script to $Scriptpath"
            $ConfigString | Out-File -FilePath $Scriptpath -Force -Encoding Utf8
        }

        # Create the MOF File if possible.
        $pass = Complete-Configuration -ConfigString $ConfigString -OutputPath $OutputPath

        if ($ShowPesterOutput)
        {
            # Write out a Summary of our parsing activities.
            Write-ProcessingHistory -Pass $Pass
        }

        if ($pass)
        {
            if ($OutputConfigurationScript)
            {
                $ConfigurationScript = Get-Item $Scriptpath
            }

            $Configuration = Get-Item $(Join-Path -Path $OutputPath -ChildPath "$ComputerName.mof") -ErrorAction SilentlyContinue
        
            if ($PassThru) {
                $files = @()
                $files += $Configuration,$ConfigurationScript
                return $files
            }
            else {
                $return = New-Object -TypeName PSObject -Property @{
                    Name                = $ConfigName
                    Configuration       = $Configuration
                    ConfigurationScript = $ConfigurationScript
                }
                return $return
            }
        }
        else
        {
            Get-Item $(Join-Path -Path $OutputPath -ChildPath "$ConfigName.ps1.error")
        }

    }
}

<#
.Synopsis
 Merge all applied GPOs for a computer into a MOF-file using the ConvertFrom-GPO function.
.DESCRIPTION
 This function will allow you to create a MOF-file of one computers all applied Group Policy Objects.
 The computer can be the local machine or a remote machine.
 For remote connections Windows Remote Management needs to be configured and port 5985 open in the firewall.
 The PowerShell function ConvertFrom-GPO is required.
.PARAMETER Computer
 The name of the computer to use as an template for the MOF-file
 .PARAMETER Path
 The folder where the MOF-file will be created.
 .PARAMETER Table
 Display table of merged GPOs.
 .PARAMETER SkipGPUpdate
 Do not execute gpupdate on computer.
.EXAMPLE
 Merge-GPOs
 Locally collect applied group policy links and merge the into one MOF-file.
.EXAMPLE
 Merge-GPOs -Computer Server1
 Remotely collect applied group policy links and merge the into one MOF-file.
.EXAMPLE
 Merge-GPOs -Computer Server1 -Path C:\Temp
 Remotely collect applied group policy links and merge the into one MOF-file in the folder C:\Temp
.EXAMPLE
 Merge-GPOs -Computer Server1 -SkipTable
 Remotely collect applied group policy links and merge the into one MOF-file but do not present the applied GPOs on screen.
 .EXAMPLE
 Merge-GPOs -Computer Server1 -SkipGPUpdate
 Will not perform a gpupdate before collecting applied group policy links and merge the into one MOF-file.
 If recent group policy changes have been made these could then be missing in the MOF-file.
.INPUTS
.OUTPUTS
.COMPONENT
.ROLE
#>
function Merge-GPOs
{
    [CmdletBinding(DefaultParameterSetName='Filters',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Computer to scan
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Computer')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Computer=$env:COMPUTERNAME,
        # Output Path that will default to an Output directory under the current Path.
        [ValidateScript( {Test-Path $_ -PathType Container})]
        [string]$Path = $(Join-Path $pwd.Path "Output"),
        # Display all merged GPOs
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false,
                   ValueFromRemainingArguments=$false,
                   Position=2,
                   ParameterSetName='Computer')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $SkipTable,
        # Do not perform GPUpdate on host
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false,
                   ValueFromRemainingArguments=$false,
                   Position=3,
                   ParameterSetName='Computer')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $SkipGPUpdate,
        [Parameter(Mandatory=$false,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$false,
        ValueFromRemainingArguments=$false,
        Position=3,
        ParameterSetName='Computer')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $ShowPesterOutput,
        [Parameter(Mandatory=$false,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$false,
        ValueFromRemainingArguments=$false,
        Position=3,
        ParameterSetName='Computer')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $OutputConfigurationScript
    )
Begin
{


$AppliedGPLink = New-Object System.Collections.ArrayList
#==========================================================================
# Function		: PingHost
# Arguments     : host, timeout
# Returns   	: boolean
# Description   : Ping a host and returns results in form of boolean
#
#==========================================================================
Function PingHost {
    param([Array]$hostlist,[Array]$ports,[Int]$timeout = "1")
    $ErrorActionPreference = "SilentlyContinue"
    $ping = new-object System.Net.NetworkInformation.Ping
    foreach ($ip in $hostlist)
    {
        $rslt = $ping.send($ip,$timeout)
        if (! $?)
        {
            return $false
        }
        else
        {
            return $true
        }
    }

}

#==========================================================================
# Function		: PortPing
# Arguments     : host, port timeout
# Returns   	: boolean
# Description   : Ping a port number and returns results in form of boolean
#
#==========================================================================
Function PortPing
{
Param([string]$srv,$port=135,$timeout=3000,[switch]$verbose)

# Test-Port.ps1
# Does a TCP connection on specified port (135 by default)

$ErrorActionPreference = "SilentlyContinue"

# Create TCP Client
$tcpclient = new-Object system.Net.Sockets.TcpClient

# Tell TCP Client to connect to machine on Port
$iar = $tcpclient.BeginConnect($srv,$port,$null,$null)

# Set the wait time
$wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)

# Check to see if the connection is done
if(!$wait)
{
    # Close the connection and report timeout
    $tcpclient.Close()
    if($verbose){Write-Host "Connection Timeout"}
    Return $false
}
else
{
    # Close the connection and report the error if there is one
    $error.Clear()
    $tcpclient.EndConnect($iar) | out-Null
    if(!$?){if($verbose){write-host $error[0]};$failed = $true}
    $tcpclient.Close()
}

# Return $true if connection Establish else $False
if($failed){return $false}else{return $true}
}
#==========================================================================
# Function		: Wait-MyJob
# Arguments     : job Ids
# Returns   	: Array of objects returned by command
# Description   : Wait for jobs and return output
#
#==========================================================================
Function Wait-MyJob
{
param
(
    # This is the Path of the GPO Backup Directory.
    [Parameter(Mandatory = $true)]
    $jobIds,
    [Parameter(Mandatory = $false)]
    [switch]
    $NoReturn
)
[int]$Timeout = 100
$sleepTime = 2
$timeElapsed =  0
$running = $true
$dicCompltedJobs = @{}
$arrReturnedData = New-Object System.Collections.ArrayList
while ($running -and $timeElapsed -le $Timeout)
{
    $running = $false

    $jobs = get-job | Where-Object{$jobIds.Contains($_.Id)}
    #Reporting job state
    $colrunningjobs = get-job | Where-Object{$jobIds.Contains($_.Id)} | Where-Object State -eq 'Running' | Select-Object -Property Name
    Foreach($runningjob in $colrunningjobs)
    {
        Write-Verbose "Waiting for job to complete on: $($runningjob.name)"
    }
    $colcompletedjobs = get-job | Where-Object{$jobIds.Contains($_.Id)} | Where-Object State -eq 'Completed' | Select-Object -Property Name
    Foreach($completedjob in $colcompletedjobs)
    {
        If (!($dicCompltedJobs.ContainsKey($completedjob.name)))
        {
            $dicCompltedJobs.Add($completedjob.name,'Completed')

            Write-Verbose "Job completed on $($runningjob.name)"
        }
    }


    Foreach($job in $jobs)
    {
        if($job.State -eq 'Running')
        {
            $running = $true
        }
    }

    Start-Sleep $sleepTime
    $timeElapsed += $sleepTime
}

$jobs = get-job | Where-Object{$jobIds.Contains($_.Id)}
Foreach($job in $jobs)
{
    if($job.State -eq 'Failed')
    {
        Write-Warning "Job failed on $($runningjob.name)"
    }
    else
    {
            Receive-Job $job | ForEach-Object{[void]$arrReturnedData.add($_)}

    }
}
#If NoRetrun is specified do not return data
if(!($NoReturn))
{
    return $arrReturnedData
}
}
}
Process
{
$bolConnectionEstablished = $false
#Test if computer responds on ping
if($(PingHost $Computer))
{
    #Test if computer accept incoming traffic on port 5985 (WinRM)
    if($(PortPing $Computer 5985 3000))
    {
        #Open session to computer
        $PSSession = New-PSSession -ComputerName $Computer

        #if GPUpdate is requested, run it remotely to get latest GP links
        if(!($SkipGPUpdate))
        {
            #Commands to refresh applied gpos
            $Script = {
                gpupdate /target:computer
            }
            #Reset jobs array
            $MyjobIds = @()
            Write-Verbose "Perform GPUPDATE [/target:computer] on $Computer"

            #Execute command remotely
            $job = Invoke-Command -Session $PSSession -ScriptBlock $Script -AsJob -JobName "$Computer"

            #Add job to array
            $MyjobIds += $job.Id

            if($VerbosePreference -eq "Continue")
            {
                #Wait for jobb and return output
                Wait-MyJob $MyjobIds
            }
            else
            {
                #Wait for jobb and do not return output
                Wait-MyJob $MyjobIds -NoReturn
            }
        }

        #Reset Jobs to wait for
        $MyjobIds = @()

        #Commands to retreive applied GPOs
        $Script = {
            $AppliedGPLink =Get-WmiObject -Namespace "ROOT\RSOP\Computer" -Class 'RSOP_GPlink' -Filter 'AppliedOrder <> 0' | Select-Object -Property GPO,appliedOrder,SOM | Sort-Object -Property appliedOrder -Descending
            return $AppliedGPLink
        }
        Write-Verbose "Collect applied GPOs from $Computer"
        #Execute command remotely
        $job = Invoke-Command -Session $PSSession -ScriptBlock $Script -AsJob -JobName "$Computer"
        #Add job to array
        $MyjobIds += $job.Id
        #Wait for job and retrive results
        $AppliedGPLink = @(Wait-MyJob $MyjobIds)
        $bolConnectionEstablished = $true
    }
    else
    {
        Write-Error -Category ConnectionError  -Message "$Computer has port 5985 closed!"
        #exit function
        Break
    }
}
else
{
    Write-Error -Category ConnectionError  -Message "$Computer not available!"
    #exit function
    Break
}
if($AppliedGPLink.count -gt 0)
{
    if($bolConnectionEstablished)
    {
        $strBackupFolder = $Path + "\MergedGPOs"
        $tmpGUId = (New-Guid).GUID.tostring()
        $script:bolDeleteSuccess = $true
        if(Test-Path -Path $strBackupFolder){try{Remove-Item -Path $strBackupFolder -Recurse -Force -Confirm:$false -ErrorAction stop ;$script:bolDeleteSuccess = $true }catch{$script:bolDeleteSuccess = $false}}
        if($script:bolDeleteSuccess)
        {
            $objBackupFolder = New-Item -ItemType Directory -Path $strBackupFolder
        }
        else
        {

            $strBackupFolder = $strBackupFolder + $tmpGUId
            Write-Verbose  "Failed to delete old folder, creating new folder with trailing GUID. $strBackupFolder"
            $objBackupFolder = New-Item -ItemType Directory -Path $strBackupFolder
        }
        #Counter for GPlinks will be used as prefix on the folde name
        $i = 1
        #Enumerate GPO links
        $arrPresentGPOsApplied = new-object System.Collections.ArrayList
        Foreach ($GPLink in $AppliedGPLink)
        {

            #Remove first part
            $GUID = $GPLink.GPO.toString().split("{")[1]

            #Remove last part
            $GUID = $GUID.toString().split("}")[0]
            $GPOName =  $((Get-GPO -Guid $GUID).DisplayName.toString() )

            #Remove non-allowed folder characters
            $strFolderName = $GPOName -replace '[\x2B\x2F\x22\x3A\x3C\x3E\x3F\x5C\x7C]', ''

            #Naming the folder with reversed numbering from the applied order to get merged the mof correctly
            $strFolderFullName = $strBackupFolder+"\"+$i+"_"+$strFolderName
            Write-Verbose "Exporting GPO: $GPOName"

            #Delete  GPO backup destination folder if already exist
            if(Test-Path -Path $strFolderFullName){Remove-Item -Path $strFolderFullName -Recurse -Force -Confirm:$false}

            #Create  GPO backup destination folder
            $BackupDestination = New-Item -ItemType Directory -Path $strFolderFullName

            #Backup GPO in folder created
            $nul=Backup-GPO -Guid $GUID -Path $BackupDestination.FullName

            #Trim GPLink SOM value
            $strSOM = $GPLink.SOM.tostring()
            #Get the value between the double qoutes.
            $strSOM = $strSOM.split('"')[1]
            #New object for presenting each GPO
            $objGPO = New-Object PSObject
            Add-Member -inputObject $objGPO -memberType NoteProperty -name "Name" -value $GPOName
            Add-Member -inputObject $objGPO -memberType NoteProperty -name "Applied Order" -value $GPLink.appliedOrder
            Add-Member -inputObject $objGPO -memberType NoteProperty -name "Merged Order" -value $i
            Add-Member -inputObject $objGPO -memberType NoteProperty -name "SOM" -value $strSOM
            #Add GPO object to array
            [VOID]$arrPresentGPOsApplied.add($objGPO)

            #Incrementing counter of GPlinks for folder names
            $i++

        }
        #Clean up
        $AppliedGPLink = ""
        $BackupDestination = ""
        $strFolderFullName = ""
        $GPOName = ""
        $GUID = ""
        $GPLink = ""
        $tmpGUId = ""
        Remove-Variable AppliedGPLink
        Remove-Variable BackupDestination
        Remove-Variable strFolderFullName
        Remove-Variable GPOName
        Remove-Variable GUID
        Remove-Variable GPLink
        Remove-Variable tmpGUId

        Write-Verbose ("Converting GPOs to MOF-file")

        $rslt = Get-ChildItem -Path $strBackupFolder -Directory -Filter "{*" -Recurse | ConvertFrom-GPO -ComputerName ($Computer+"_Merged") -OutputPath $Path -OutputConfigurationScript:$OutputConfigurationScript -ShowPesterOutput:$ShowPesterOutput

    }#end if connectionestablised
}
else
{
    Write-Output "No applied GPLink found!"
}

}
End
{
    #Check if objBackupFolder exist
    if($objBackupFolder)
    {
        #Check if objBackupFolder path exist
        if(Test-Path $objBackupFolder)
        {
            #Delete exported files
            remove-item $objBackupFolder -Recurse -Force -Confirm:$false
        }
    }
    #User selects if the table of merged GPOs should not be presented
    if(!($SkipTable))
    {
        $arrPresentGPOsApplied | Format-Table -Property Name,'Applied Order','Merged Order',SOM -AutoSize
    }
    #Verify that ConvertFrom-GPO has yielded an output
    if($rslt)
    {
        Write-Output "Output file: $($rslt.Fullname)"
    }
    #Clean up
    $objBackupFolder = ""
    $rslt = ""
    $arrPresentGPOsApplied = ""
    Remove-Variable rslt
    Remove-Variable arrPresentGPOsApplied
    Remove-Variable objBackupFolder

}
}

Export-ModuleMember -Function ConvertFrom-GPO, Merge-GPOs
