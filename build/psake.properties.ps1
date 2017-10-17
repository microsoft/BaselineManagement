###############################################################################
# Customize these properties and tasks for your module.
###############################################################################

Properties {
    # ----------------------- Basic properties --------------------------------

    # The root directories for the module's docs, src and test.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $RootDir = Resolve-Path "$PSScriptRoot\.."
        
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $SrcRootDir  = "$RootDir\src"
    
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $TestRootDir = "$RootDir\tests"

    # Set the Module save path to the current environment. 
    if ( $null -eq $Env:AGENT_HOMEDIRECTORY)
    {
        $currentUserModuleDirectory = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
    }
    else 
    {
        $currentUserModuleDirectory = "$Env:AGENT_HOMEDIRECTORY\agent\worker\Modules"
    }

    # The name of your module should match the basename of the PSD1 file.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ModuleName = "BaselineManagement"
    # The $releaseDir is where module files and updatable help files are staged for signing, install and publishing.
    
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $releaseDir = "$RootDir\release"

    # The local installation directory for the install task. Defaults to your home Modules location.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    #$InstallPath = Join-Path (Split-Path $profile.CurrentUserAllHosts -Parent) `
    #    "Modules\$ModuleName\$((Test-ModuleManifest -Path "$SrcRootDir\$ModuleName.psd1").Version.ToString())"

    # Default Locale used for help generation, defaults to en-US.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $DefaultLocale = 'en-US'

    # Items in the $Exclude array will not be copied to the $releaseDir e.g. $Exclude = @('.gitattributes')
    # Typically you wouldn't put any file under the src dir unless the file was going to ship with
    # the module. However, if there are such files, add their $SrcRootDir relative paths to the exclude list.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $Exclude = @('BaselineManagement.psd1')

    # ------------------ Script analysis properties ---------------------------

    # Enable/disable use of PSScriptAnalyzer to perform script analysis.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ScriptAnalysisEnabled = $true

    # When PSScriptAnalyzer is enabled, control which severity level will generate a build failure.
    # Valid values are Error, Warning, Information and None.  "None" will report errors but will not
    # cause a build failure.  "Error" will fail the build only on diagnostic records that are of
    # severity error.  "Warning" will fail the build on Warning and Error diagnostic records.
    # "Any" will fail the build on any diagnostic record, regardless of severity.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    [ValidateSet('Error', 'Warning', 'Any', 'None')]
    $ScriptAnalysisFailBuildOnSeverityLevel = 'Error'

    # Path to the PSScriptAnalyzer settings file.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ScriptAnalyzerSettingsPath = "$PSScriptRoot\..\tests\ScriptAnalyzerSettings.psd1"

    # ------------------- Script signing properties ---------------------------

    # Set to $true if you want to sign your scripts. You will need to have a code-signing certificate.
    # You can specify the certificate's subject name below. If not specified, you will be prompted to
    # provide either a subject name or path to a PFX file.  After this one time prompt, the value will
    # saved for future use and you will no longer be prompted.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ScriptSigningEnabled = $false

    # Specify the Subject Name of the certificate used to sign your scripts.  Leave it as $null and the
    # first time you build, you will be prompted to enter your code-signing certificate's Subject Name.
    # This variable is used only if $SignScripts is set to $true.
    #
    # This does require the code-signing certificate to be installed to your certificate store.  If you
    # have a code-signing certificate in a PFX file, install the certificate to your certificate store
    # with the command below. You may be prompted for the certificate's password.
    #
    # Import-PfxCertificate -FilePath .\myCodeSigingCert.pfx -CertStoreLocation Cert:\CurrentUser\My
    #
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $CertSubjectName = $null

    # Certificate store path.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $CertPath = "Cert:\"

    # -------------------- File catalog properties ----------------------------

    # Enable/disable generation of a catalog (.cat) file for the module.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $CatalogGenerationEnabled = $true

    # Select the hash version to use for the catalog file: 1 for SHA1 (compat with Windows 7 and
    # Windows Server 2008 R2), 2 for SHA2 to support only newer Windows versions.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $CatalogVersion = 2

    # ---------------------- Testing properties -------------------------------

    # Enable/disable Pester code coverage reporting.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $CodeCoverageEnabled = $false

    # CodeCoverageFiles specifies the files to perform code coverage analysis on. This property
    # acts as a direct input to the Pester -CodeCoverage parameter, so will support constructions
    # like the ones found here: https://github.com/pester/Pester/wiki/Code-Coverage.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $CodeCoverageFiles = "$SrcRootDir\*.ps1", "$SrcRootDir\*.psm1"

    # -------------------- Publishing properties ------------------------------

    # Your NuGet API key for the PSGallery.  Leave it as $null and the first time you publish,
    # you will be prompted to enter your API key.  The build will store the key encrypted in the
    # settings file, so that on subsequent publishes you will no longer be prompted for the API key.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $NuGetApiKey = '24e9ed68-22cf-48b5-8241-0c4e340009dc'

    # Name of the repository you wish to publish to. If $null is specified the default repo (PowerShellGallery) is used.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $PublishRepository = $null

    # Path to the release notes file.  Set to $null if the release notes reside in the manifest file.
    # The contents of this file are used during publishing for the ReleaseNotes parameter.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ReleaseNotesPath = "$PSScriptRoot\ReleaseNotes.md"

    # ----------------------- Misc properties ---------------------------------

    # In addition, PFX certificates are supported in an interactive scenario only,
    # as a way to import a certificate into the user personal store for later use.
    # This can be provided using the CertPfxPath parameter. PFX passwords will not be stored.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $SettingsPath = "$env:LOCALAPPDATA\Plaster\NewModuleTemplate\SecuredBuildSettings.clixml"

    # Specifies an output file path to send to Invoke-Pester's -OutputFile parameter.
    # This is typically used to write out test results so that they can be sent to a CI
    # system like AppVeyor.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $TestOutputFile = "TEST_$((Get-Date).ToShortDateString().Replace('/','') + '_' + (Get-Date).ToShortTimeString().Replace(':','')).xml"

    # Specifies the test output format to use when the TestOutputFile property is given
    # a path.  This parameter is passed through to Invoke-Pester's -OutputFormat parameter.
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $TestOutputFormat = "NUnitXml"
}


Task Test.Unit.Before {
Write-host $pwd
    Microsoft.PowerShell.Management\Push-Location -LiteralPath $TestRootDir\unit
    Write-host $pwd
}

Task Test.Unit.After {

    Microsoft.PowerShell.Management\Pop-Location
}

Task Test.Integration.Before {

    Microsoft.PowerShell.Management\Push-Location -LiteralPath $TestRootDir\integration
} 

Task Test.Integration.After {

    Microsoft.PowerShell.Management\Pop-Location

    Remove-Module $ModuleName -ErrorAction SilentlyContinue
}

Task Build.Before {
# Get the lsit of cmdlets that are exporte from the psm1 file
    Write-Verbose "Parsing $("$SrcRootDir\$ModuleName.psm1")"

    $AST = [System.Management.Automation.Language.Parser]::ParseFile(
        "$SrcRootDir\$ModuleName.psm1",
        [ref] $null,
        [ref] $Null
    )

    # Get the Export-ModuleMember details from the moduel file
    $ModuleMember = $AST.Find({
        $args[0] -is [System.Management.Automation.Language.CommandAst] -and 
            $args[0].CommandElements.Value -eq 'Export-ModuleMember' }, $true) 
    
    $values = $ModuleMember.Parent.PipelineElements.commandelements

    # If a single function is exported then the elements array is not returned, so this just checks for an elements attribute.
    if ( $values.Elements )
    {
        $values = $values.Elements.Value
    }
    else 
    {
        $values = $values.Value
    }
    
    # Set a script scope variable so that the core build task can access the vaules. 
    $script:exportedCommands = $values

    Write-Verbose "Exported Commands: $values"
}

Task Build.After {
    # Update the module manifest in the release that was just built using the existing Maj.Min numbers from the manifest. 
    $PsModulePath = "$PsScriptRoot\..\release\$ModuleName\$ModuleName.psd1"
    [version] $PsModuleVersion = (Import-PowerShellDataFile -Path $PsModulePath).ModuleVersion

    if ($nulll -eq $Env:BUILD_BUILDNUMBER)
    {
        $BUILDNUMBER = '1000'
    }
    else
    {
        $BUILDNUMBER = $Env:BUILD_BUILDNUMBER
        Write-Host "##vso[task.setvariable variable=MajorVersion]$($PsModuleVersion.Major)"
        Write-Host "##vso[task.setvariable variable=MinorVersion]$($PsModuleVersion.Minor)"
    }

    Update-ModuleManifest -Path $PsModulePath -ModuleVersion "$($PsModuleVersion.Major).$($PsModuleVersion.Minor).$BUILDNUMBER"
}

Task Deploy.Before {
    Remove-Item -Path $env:USERPROFILE\documents\WindowsPowerShell\Modules\$ModuleName `
                -Recurse `
                -Force `
                -ErrorAction SilentlyContinue
}

Task Deploy.After {

}