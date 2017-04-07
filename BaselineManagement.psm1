<#
.Synopsis
   This is a universal ConvertTo-DSC function that converts GPO, SCMxml or SCMjson to DSC Configuration script.
.DESCRIPTION
   We utilize the type of object passed in to determine which function to call.  Directories are associated with GPO backups, Objects are associated with GPO objects or JSON objects and XML with XML.
.EXAMPLE
   dir .\<GPO Backup GUID> | ConvertTo-DSC
.EXAMPLE
   dir .\scm.xml | ConvertTo-DSC
.EXAMPLE
   dir .\scm.json | ConvertTo-DSC
.EXAMPLE
   Backup-GPO <GPO Name> | ConvertTo-DSC
.INPUTS
   Any supported baseline to be converted into DSC.
.OUTPUTS
   Output will come from calling cmdlet ConvertFrom-GPO, ConvertFrom-SCMXML, and ConvertFrom-SCMJSON.
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function ConvertTo-DSC
{
    [CmdletBinding()]
    param
    (
        # This is the Path to either a SCM/JSON file or a GPO Backup directory.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName="Path")]
        [ValidateScript({Test-Path $_})]
        [Alias("BackupDirectory")]
        [string]$Path,

        # This is either a GPO Backup object or a JSON/XML object.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName="Object")]
        [Psobject]$Object,

        # This is the hard coded stage that you can just force it into the type of input.
        [Parameter()]
        [ValidateSet("ADMX", "GPO", "SCMxml", "SCMjson")]
        [string]$Type,
        
        # Output Path that will default to an Output directory under the current Path.
        [ValidateScript({Test-Path $_})]
        [string]$OutputPath = $(Join-Path $pwd.Path "Output"),

        # ComputerName for Node processing.
        [string]$ComputerName = "localhost",

        # This determines whether or not to output a ConfigurationScript in addition to the localhost.mof
        [switch]$OutputConfigurationScript
    )
        
    Process
    {
        $Parameter = $null
        # Determine the Type of input we are dealing with.
        switch($Type)
        {
            Default
            {
                Write-Verbose "Trying to determine type of input from ParameterSet $($PSCmdlet.ParameterSetName)"
                switch ($PSCmdlet.ParameterSetName)
                {
                    "Path"
                    {
                        $item = Get-Item -Path $Path
                        if ($item -is [System.IO.DirectoryInfo])
                        {
                            Write-Verbose "Assuming GPO since Directory was given for Path"
                            $Type = "GPO"
                        }
                        else
                        {
                            switch ($item.Extension)
                            {
                                ".json" { $Type = "SCMjson" }
                                ".xml" { $Type = "SCMxml" }
                            }
                        }    
                        
                        $parameter = $item
                    }

                    "Object"
                    {
                        switch ($Object)
                        {
                            {$_ -is [XML]} { $Type = "SCMxml" }
                            {$_ -is [Microsoft.GroupPolicy.GpoBackup]} { $Type = "GPO" } 
                            {$_ -is [PSCustomObject]} { Write-Verbose "Assuming JSON if object is a custom Object"; $Type = "SCMjson"}
                        }

                        $Parameter = $object
                    }
                }
            }
        }

        # Call the appropriate conversion function based on input.
        $scriptblock = [scriptblock]::Create('param($param) ConvertFrom-' + $Type + ' @param')
        # Pass our parameters (minus the Type) to our Conversion cmdlet.
        $PSBoundParameters.Remove("Type") | Out-Null
        return Invoke-Command -ScriptBlock $scriptblock -ArgumentList $PSBoundParameters
    }
}

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
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function ConvertFrom-GPO
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        # This is the Path of the GPO Backup Directory.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName="Path")]
        [ValidateScript({Test-Path $_})]
        [string]$Path,
        
        # This is the GPO Object returned from Backup-GPO.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName="GPO")]
        [Psobject]$GPO,

        # Output Path that will default to an Output directory under the current Path.
        [ValidateScript({Test-Path $_})]
        [string]$OutputPath = $(Join-Path $pwd.Path "Output"),

        # ComputerName for Node processing.
        [string]$ComputerName = "localhost",

        # This determines whether or not to output a ConfigurationScript in addition to the localhost.mof
        [switch]$OutputConfigurationScript
    )

    # If we are passed a GPO object, we can get the path to the files from that object.
    if ($PSCmdlet.ParameterSetName -eq "GPO")
    {
        Write-Verbose "Gathering GPO data from $($GPO.BackupDirectory)"
        $polFiles = Get-ChildItem -Path $(Join-Path $GPO.BackupDirectory "{$($GPO.Id)}") -Filter registry.pol -Recurse

        $AuditCSVs = Get-ChildItem -Path $(Join-Path $GPO.BackupDirectory "{$($GPO.Id)}") -Filter Audit.csv -Recurse

        $GPTemplateINFs = Get-ChildItem -Path $(Join-Path $GPO.BackupDirectory "{$($GPO.Id)}") -Filter GptTmpl.inf -Recurse

        $RegistryXMLs = Get-ChildItem -Path $(Join-Path $GPO.BackupDirectory "{$($GPO.Id)}") -Filter Registry.xml -Recurse
    }
    else # They passed in a directory to the GPO backup, so grab our files from there.
    {
        Write-Verbose "Gathering GPO Data from $Path"
        $polFiles = Get-ChildItem -Path $Path -Filter registry.pol -Recurse

        $AuditCSVs = Get-ChildItem -Path $Path -Filter Audit.csv -Recurse

        $GPTemplateINFs = Get-ChildItem -Path $Path -Filter GptTmpl.inf -Recurse
        
        $RegistryXMLs = Get-ChildItem -Path $Path -Filter Registry.xml -Recurse
    }
    
    # Start tracking Processing History.
    Clear-ProcessingHistory
    
    # Create the Configuration String
    $ConfigString = Write-DSCString -Configuration -Name "DSCFromGPO"
    # Add any resources
    $ConfigString += Write-DSCString -ModuleImport -ModuleName PSDesiredStateConfiguration, AuditPolicyDSC, SecurityPolicyDSC, GPOtoDSC
    # Add Node Data
    $configString += Write-DSCString -Node -Name $ComputerName
    
    # Loop through each Pol file.
    foreach ($polFile in $polFiles)
    {
        # Reaad each POL file found.
        Write-Verbose "Reading Pol File ($($polFile.FullName))"
        $registryPolicies = Read-PolFile -Path $polFile.FullName

        # Loop through every policy in the Pol File.
        Foreach ($Policy in $registryPolicies)
        {
            # Convert each Policy Registry object into a Resource Block and add it to our Configuration string.
            $ConfigString += Write-POLRegistryData -Data $Policy
        }
    }
        
    $i = 0;
    # Loop through each Audit CSV in the GPO Directory.
    foreach ($AuditCSV in $AuditCSVs)
    {
        $parameters = @{CSVPAth=$AuditCSV.FullName;Force=$True}
        # Add our CSV path to a resource block and concatenate with our Configuration string.
        $ConfigString += Write-DSCString -Resource -Type "AuditPolicyCSV" -Name $($AuditCSV.Name + "_$i") -Parameters $parameters
        $i++
    }

    # Loop through all the GPTemplate files.
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
                switch ($key)
                {
                    "Service General Setting"
                    {
                        $ConfigString += Write-INFServiceData -Service $subkey -ServiceData $ini[$key][$subKey]
                    }

                    "Registry Values"
                    {
                        $ConfigString += Write-INFRegistryData -Key $subkey -ValueData $ini[$key][$subKey]
                    }

                    "File Security"
                    {
                        $ConfigString += Write-INFFileSecurityData -Path $subkey -ACLData $ini[$key][$subKey]
                    }
                
                    "Privilege Rights"
                    {
                        $ConfigString += Write-INFPrivilegeData -Privilege $subkey -PrivilegeData $ini[$key][$subKey]
                    }
                
                    "Kerberos Policy"
                    {
                        $ConfigString += Write-INFSecuritySettingData -Key $subKey -SecurityData $ini[$key][$subkey]
                    }
                
                    "Registry Keys"
                    {
                        $ConfigString += Write-INFRegistryACLData -Path $subkey -ACLData $ini[$key][$subKey]
                    }
                
                    "System Access"
                    {
                        $ConfigString += Write-INFSecuritySettingData -Key $subKey -SecurityData $ini[$key][$subkey]
                    }
                }
            }
        }
    }

    # There is also SOMETIMES a RegistryXML file that contains some additional registry information.
    foreach ($RegistryXML in $RegistryXMLs)
    {
        Write-Verbose "Reading RegistryXML ($($RegistryXML.FullName))"
        # Grab the XML info.
        [xml]$Settings = Get-Content $RegistryXML.FullName

        $Settings = $RegistryXML.RegistrySettings.Registry

        # Loop through every registry setting.
        foreach ($Setting in $Settings)
        {
            $ConfigString += Write-GPORegistryXMLData -XML $Setting
        }
    }

    # Close out the Node Block and the configuration.
    $ConfigString += Write-DSCString -CloseNodeBlock 
    $ConfigString += Write-DSCString -CloseConfigurationBlock
    $ConfigString += Write-DSCString -InvokeConfiguration -Name DSCFromGPO -OutputPath $OutputPath
        
    # If the switch was specified, output a Configuration PS1 regardless of success or failure.
    if ($OutputConfigurationScript)
    {
        if (!(Test-Path $OutputPath))
        {
            mkdir $OutputPath
        }
                
        $Scriptpath = Join-Path $OutputPath "DSCFromGPO.ps1"
        Write-Verbose "Outputting Configuration SCript to $Scriptpath"
        $ConfigString | Out-File -FilePath $Scriptpath -Force
    }

    # Create the MOF File if possible.
    $pass = Complete-Configuration -ConfigString $ConfigString -OutputPath $OutputPath
    
    # Write out a Summary of our parsing activities.
    return Write-ProcessingHistory -Pass $Pass
}

<#
.Synopsis
   This cmdlet converts SCMxml baselines into DSC Configurations.
.DESCRIPTION
   This cmdlet will look at all of the settings in an SCM XML file and convert them into DSC resources inside of a configuration.
.EXAMPLE
   dir .\SCM.XML | ConvertFROM-SCMXML -OutputConfigurationScript
.EXAMPLE
   ConvertFrom-SCMXML -Path .\SCM.XML -OutputConfigurationScript.
.EXAMPLE
   [Xml]$xml = Get-Content .\SCM.XML
   ConvertFrom-SCMXML -XML $xml
.INPUTS
   Either the XML content of a SCM baseline or the file itself.
.OUTPUTS
   Success or failure will yield a localhost.mof or a failed configuration file as well as an optional ConfigurationScript ps1 file.
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
Function ConvertFrom-SCMXML
{
    [CmdletBinding()]
    param
    (
        # This is the XML object itself.
        [Parameter(Mandatory=$true, ParameterSetName="XML", ValueFromPipeLine=$true)]
        [XML]$XML,
        
        # This is the Path to the XML file.
        [Parameter(Mandatory=$true, ParameterSetName="Path", ValueFromPipeLine=$true)]
        [ValidateScript({Test-Path $_})]
        [String]$Path,

        # Output Path that will default to an Output directory under the current Path.
        [Parameter()]
        [String]$OutputPath = $(Join-Path $pwd.Path "output"),

        # ComputerName for Node processing.
        [string]$ComputerName = "localhost",

        # This determines whether or not to output a ConfigurationScript in addition to the localhost.mof
        [switch]$OutputConfigurationScript
    )

    # If they passed in a path we have to grab the XML object from it.
    if ($PSCmdlet.ParameterSetName -eq "Path")
    {
        [XML]$XML = Get-Content $Path
    }

    # Grab the comments from the SCM Baline XML.
    $BaselineComment = $xml.SCMPackage.Baseline.Description.Trim()

    # Start tracking Processing History.
    Clear-ProcessingHistory
    
    # Create the Configuration String
    $ConfigString = Write-DSCString -Configuration -Name DSCFromSCMXML -Comment $BaselineComment
    # Add any resources
    $ConfigString += Write-DSCString -ModuleImport -ModuleName PSDesiredStateConfiguration, AuditPolicyDSC, SecurityPolicyDSC
    # Add Node Data
    $ConfigString += Write-DSCString -Node -Name $ComputerName
    
    # We need to setup a namespace to properly search the XML.
    $namespace = @{e="http://schemas.microsoft.com/SolutionAccelerator/SecurityCompliance"}
    
    # Grab all the DiscoveryInfo objects in the XML. They determine how to find the setting in question.
    $results = (Select-XML -XPath "//e:SettingDiscoveryInfo" -Xml $xml -Namespace $namespace).Node

    # If we found some DiscoveryInfo objects.
    if ($results -ne $null -and $results.Count -gt 0)
    {
        foreach ($node in $results)
        {
            $Setting = "../.."
            $SettingDiscoveryInfo = ".."
            
            # Set up some variables for easy manipulation of values.
            
            # This is how to find it (.Wmidiscoveryinfo -> class, name etc.) It's only one level back in GeneratedScript
            $settingDiscoveryInfo = $node.SelectNodes($SettingDiscoveryInfo)
                
            # Grab the ID/Name from the Setting value.
            $ID = $node.SelectNodes($Setting).id.Trim("{").TrimEnd("}")
            
            # Find the ValueData using the ID.
            $valueNodeData = (Select-XML -XPath "//e:SettingRef[@setting_ref='{$($id)}']" -Xml $xml -Namespace $namespace).Node
                        
            if ($valueNodeData -eq $null)
            {
                Write-Error "Could not find ValueNodeData of $id" 
                continue
            }
            
            # Determine the DiscoveryInfo Type.                       
            switch ($node.DiscoveryType)
            {
                "Registry" 
                {
                    $ConfigString += Write-XMLRegistryData -DiscoveryData $node -ValueData $valueNodeData
                }
                
                "Script"
                {
                    $ConfigString += Write-XMLScriptData -DiscoveryData $node -ValueData $valueNodeData
                }
                
                "WMI"
                {
                    $ConfigString += Write-XMLWMIData -DiscoveryData $node -ValueData $valueNodeData
                }

                "AdvancedAuditPolicy"
                {
                    $ConfigString += Write-XMLAuditData -DiscoveryData $node -ValueData $valueNodeData
                }
                
                "GeneratedScript (User Rights Assignment)"
                {
                    $ConfigString += Write-XMLPrivilegeData -DiscoveryData $node -ValueData $valueNodeData
                }
            }
        }
    }

    # Close out our configuration string.
    $ConfigString += Write-DSCString -CloseNodeBlock
    $ConfigString += Write-DSCString -CloseConfigurationBlock
    $ConfigString += Write-DSCString -InvokeConfiguration -Name DSCFromSCMXML -OutputPath $OutputPath
    
    # If the switch was specified.  Output a Configuration PS1 regardless of success/failure.
    if ($OutputConfigurationScript)
    {
        if (!(Test-Path $OutputPath))
        {
            mkdir $OutputPath
        }

        $Scriptpath = Join-Path $OutputPath "DSCFromSCMXML.ps1"
        $ConfigString | Out-File -FilePath $Scriptpath -Force
    }

    # Try to compile the MOF file.
    $pass = Complete-Configuration -ConfigString $ConfigString -OutputPath $OutputPath
    
    # Write Summary Data on processing activities.
    return Write-ProcessingHistory -Pass $Pass
}

<#
.Synopsis
   This cmdlet converts from SCMJSON into DSC.
.DESCRIPTION
   This cmdlet will look at all baselines entries within an SCM JSON file and convert them to DSC.
.EXAMPLE
   ConvertFrom-SCMJSON -Path .\SCM.Json
.EXAMPLE
   dir .\scm.json | ConvertFrom-SCMJSON -OutputConfigurationScript
.INPUTS
   The SCM JSON File.
.OUTPUTS
   Success or Failure will yield detailed results along with a localhost.mof if successful or error file if unsuccessful.  It also yields a ConfigurationScript on request.
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function ConvertFrom-SCMJSON
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        # This is the Path to the JSON file.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName="Path")]
        [ValidateScript({Test-Path $_})]
        [string]$Path,
        
        # Output Path that will default to an Output directory under the current Path.        
        [ValidateScript({Test-Path $_})]
        [string]$OutputPath = $(Join-Path $pwd.Path "Output"),

        # ComputerName for Node processing.
        [string]$ComputerName = "localhost",

        # This determines whether or not to output a ConfigurationScript in addition to the localhost.mof
        [switch]$OutputConfigurationScript
    )
    
    # JSON can be tricky to parse, so we have to put it in a Try Block in case it's not properly formatted.   
    Try
    {
        $JSON = Get-Content -Path $Path | ConvertFrom-Json
    }
    Catch
    {
        Write-Error $_
        Write-Warning "Unable to parse JSON at path $Path - Exiting"
        continue
        return
    }
    
    # Start tracking Processing History.
    Clear-ProcessingHistory
    
    # Create the Configuration String
    $ConfigString = Write-DSCString -Configuration -Name DSCFromSCMJSON
    # Add any resources
    $ConfigString += Write-DSCString -ModuleImport -ModuleName PSDesiredStateConfiguration, AuditPolicyDSC, SecurityPolicyDSC
    # Add Node Data
    $ConfigString += Write-DSCString -Node -Name $computername
    
    # JSON is pretty straightforward where it keeps the individual settings.
    # These are the registry settings.
    $registryPolicies = $JSON.properties.RulesetsCollection.BaselineRuleset.rules.BaselineRegistryRule

    # Loop through all the registry settings.
    Foreach ($Policy in $registryPolicies)
    {
        $ConfigString += Write-JSONRegistryData -RegistryData $Policy
    }

    # Grab the Audit policies.
    $AuditPolicies = $JSON.properties.RulesetsCollection.BaselineRuleset.rules.BaselineAuditPolicyRule
    
    # Loop through the Audit Policies.
    foreach ($Policy in $AuditPolicies)
    {
        $ConfigString += Write-JSONAuditData -AuditData $Policy
    }

    # Grab all the Security Policy Settings.
    $securityPolicies = $JSON.properties.RulesetsCollection.BaselineRuleset.rules.BaselineSecurityPolicyRule
    
    # Loop through the Security Policies.
    foreach ($Policy in $securityPolicies)
    {
        # Security Policies can have a variety of types as they are represenations of the GPTemp.inf.
        # Determine which one the current setting is and apply.
        switch ($Policy.SectionName)
        {
            "Service General Setting"
            {

            }

            "Registry Values"
            {

            }

            "File Security"
            {

            }
                
            "Privilege Rights"
            {            
                $ConfigString += Write-JSONPrivilegeData -PrivilegeData $Policy
            }
                
            "Kerberos Policy"
            {
                
            }
                
            "Registry Keys"
            {

            }
                
            "System Access"
            {

            }
        }
    }
    
    # Close out the Configuration block.
    $ConfigString += Write-DSCString -CloseNodeBlock
    $ConfigString += Write-DSCString -CloseConfigurationBlock
    $ConfigString += Write-DSCString -InvokeConfiguration -Name DSCFromSCMJSON -OutputPath $OutputPath
    
    # If the switch was specified, output a Configuration Script regardless of success/failure.
    if ($OutputConfigurationScript)
    {
        if (!(Test-Path $OutputPath))
        {
            mkdir $OutputPath
        }
        
        $Scriptpath = Join-Path $OutputPath "DSCFromSCMJSON.ps1"
        $ConfigString | Out-File -FilePath $Scriptpath -Force
    }

    # Try to compile configuration.
    $pass = Complete-Configuration -ConfigString $ConfigString -OutputPath $OutputPath
    
    # Write out Summary data of parsing history.
    return Write-ProcessingHistory -Pass $Pass
}
