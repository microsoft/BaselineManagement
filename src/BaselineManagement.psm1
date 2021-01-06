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
        [Alias('BackupDirectory')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
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
        [Alias('DisplayName')]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
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

        # If ConfigName was passed from a GPO Backup, it might contain spaces
        if ($ConfigName.ToCharArray() -contains ' ') {
            $ConfigName = $ConfigName -replace ' ',''
            Write-Warning "ConvertFrom-GPO: removed spaces from configuration name $ConfigName"
        }
        # Create the Configuration String
        Write-Warning "Bound parameter: $($PSBoundparameters.Keys)"
        $ConfigString = Write-DSCString -Configuration -Name $ConfigName
        # Add required modules
        Write-Verbose "CALL Write-DSCString: $NeededModules"
        $ConfigString += Write-DSCString -ModuleImport -ModuleName $NeededModules
        # Add node data
        $ConfigString += Write-DSCString -Node -Name $ComputerName
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
            Throw $_
            return
        }

        Write-Verbose "Gathering GPO Data from $resolvedPath"

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

        # This section collects content from (Security) INF files
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
            $NewOutputPath = New-Item $OutputPath -ItemType Directory -Force
        }

        # If the switch was specified, output a Configuration PS1 regardless of success or failure.
        if ($OutputConfigurationScript)
        {
            $Scriptpath = Join-Path $OutputPath "$ConfigName.ps1"
            Write-Verbose "Output configuration script to $Scriptpath"
            $ConfigString | Out-File -FilePath $Scriptpath -Force -Encoding Utf8
        }

        # Create the MOF File if possible.
        $pass = Complete-Configuration -ConfigString $ConfigString -OutputPath $OutputPath

        if ($ShowPesterOutput)
        {
            # Write out a Summary of our parsing activities.
            Write-ProcessingHistory -Pass $Pass -OutputPath $OutputPath
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
 Merge all applied GPOs into a MOF-file using the ConvertFrom-GPO function.
.DESCRIPTION
 This function will allow you to create a MOF-file of one computers all applied Group Policy Objects.
 The PowerShell function ConvertFrom-GPO is required.
 .PARAMETER Path
 The folder where the MOF-file will be created.
 .PARAMETER Table
 Display table of merged GPOs.
 .PARAMETER SkipGPUpdate
 Do not execute gpupdate on computer.
.EXAMPLE
 Merge-GPOs
 Collect applied group policy links and merge the into one MOF-file.
.EXAMPLE
 Merge-GPOs -Path C:\Temp
 Collect applied group policy links and merge the into one MOF-file in the folder C:\Temp
.EXAMPLE
 Merge-GPOs -SkipTable
 Collect applied group policy links and merge the into one MOF-file but do not present the applied GPOs on screen.
 .EXAMPLE
 Merge-GPOs -SkipGPUpdate
 Will not perform a gpupdate before collecting applied group policy links and merge the into one MOF-file.
 If recent group policy changes have been made these could then be missing in the MOF-file.

#>
function Merge-GPOs
{
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        # Default to an Output directory under the current Path.
        [string]
        $Path = $(Join-Path $pwd.Path "Output"),

        # Do not perform GPUpdate on host
        [Parameter()]
        [switch]
        $SkipGPUpdate,

        [Parameter()]
        [switch]
        $ShowPesterOutput,

        [Parameter()]
        [switch]
        $OutputConfigurationScript
    )

    Begin {
        $AppliedGPLink = New-Object System.Collections.ArrayList
    }

    Process {

        if(!($SkipGPUpdate))
        {
            $gpudpate = Invoke-GPUpdate -Target 'Computer'
        }

        # Retreive applied GPOs
        Write-Verbose "Collecting applied GPOs"
        $AppliedGPLink =Get-WmiObject -Namespace "ROOT\RSOP\Computer" -Class 'RSOP_GPlink' -Filter 'AppliedOrder <> 0' | Select-Object -Property GPO,appliedOrder,SOM | Sort-Object -Property appliedOrder -Descending

        if($AppliedGPLink.count -gt 0) {
            $tmpGUId = (New-Guid).GUID
            $strBackupFolder = $Path + "\MergedGPOs" + $tmpGUId
            $objBackupFolder = New-Item -ItemType Directory -Path $strBackupFolder -Force
        
            # Counter for GPlinks will be used as prefix on the folder name
            $i = 1
            # Enumerate GPO links
            $arrPresentGPOsApplied = new-object System.Collections.ArrayList
            Foreach ($GPLink in $AppliedGPLink)
            {
                Write-Verbose "Processing $($GPLink.GPO)"

                if ('RSOP_GPO.id="LocalGPO"' -eq $GPLink.GPO) {
                    $GPOName = 'Local'
                }
                else {
                    # Remove first part
                    $GUID = $GPLink.GPO.toString().split("{")[1]

                    # Remove last part
                    $GUID = $GUID.toString().split("}")[0]
                    $GPOName =  $((Get-GPO -Guid $GUID).DisplayName.toString() )
                }

                # Remove non-allowed folder characters
                $strFolderName = $GPOName -replace '[\x2B\x2F\x22\x3A\x3C\x3E\x3F\x5C\x7C]', ''

                # Naming the folder with reversed numbering from the applied order to get merged the mof correctly
                $strFolderFullName = $strBackupFolder+"\"+$i+"_"+$strFolderName
                Write-Verbose "Exporting GPO: $GPOName"

                # Create  GPO backup destination folder
                $BackupDestination = New-Item -ItemType Directory -Path $strFolderFullName

                # Backup GPO in folder created
                $nul=Backup-GPO -Guid $GUID -Path $BackupDestination.FullName

                # Trim GPLink SOM value
                $strSOM = $GPLink.SOM.tostring()
                # Get the value between the double qoutes.
                $strSOM = $strSOM.split('"')[1]
                # New object for presenting each GPO
                $objGPO = New-Object PSObject
                Add-Member -inputObject $objGPO -memberType NoteProperty -name "Name" -value $GPOName
                Add-Member -inputObject $objGPO -memberType NoteProperty -name "Applied Order" -value $GPLink.appliedOrder
                Add-Member -inputObject $objGPO -memberType NoteProperty -name "Merged Order" -value $i
                Add-Member -inputObject $objGPO -memberType NoteProperty -name "SOM" -value $strSOM
                # Add GPO object to array
                [VOID]$arrPresentGPOsApplied.add($objGPO)

                # Incrementing counter of GPlinks for folder names
                $i++

            }

            Write-Verbose ("Converting GPOs to MOF-file")

            $rslt = Get-ChildItem -Path $strBackupFolder -Directory -Filter "{*" -Recurse | ForEach-Object FullName | ConvertFrom-GPO -ConfigName "MergedGroupPolicy_$Env:ComputerName" -OutputPath $Path -OutputConfigurationScript:$OutputConfigurationScript -ShowPesterOutput:$ShowPesterOutput
        }
        else {
            Write-Error "No applied GPLink found!"
        }
    }

    End
    {
        # Check if objBackupFolder exist
        if($objBackupFolder)
        {
            # Check if objBackupFolder path exist
            if(Test-Path $objBackupFolder)
            {
                # Delete exported files
                $delBackupFolder = remove-item $objBackupFolder -Recurse -Force -Confirm:$false
            }
        }

        # Add details about the Group Policies that were merged to the object returned by ConvertFrom-GPO
        $policyDetails = $arrPresentGPOsApplied
        Add-Member -inputObject $rslt -memberType NoteProperty -name 'PolicyDetails' -value $policyDetails
        
        # ConvertFrom-GPO output
        return $rslt

    }
}

Export-ModuleMember -Function ConvertFrom-GPO, Merge-GPOs
