###############################################################################
# Dot source the customized properties and extension tasks.
###############################################################################
. $PSScriptRoot\psake.properties.ps1
###############################################################################
# Private properties.
###############################################################################
Properties {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ModuleOutDir = "$releaseDir\$ModuleName"
}
###############################################################################
# Add support functions.
###############################################################################
Include "$PsScriptRoot\build_utils.ps1"
Include "$PsScriptRoot\..\tests\test_utils.ps1"
###############################################################################
# Core task implementations. Avoid modifying these tasks.
###############################################################################

Task default

Task Init -requiredVariables releaseDir {
    
    if ($RootDir.ToString().Length -lt 3)
    {
        Write-Warning "`$RootDir = $RootDir"
        throw "Project path cannot point to the root of a drive."
    }

    if (!(Test-Path -LiteralPath $releaseDir)) 
    {
        New-Item $releaseDir -ItemType Directory -Verbose:$VerbosePreference > $null
    }
    else 
    {
        Write-Verbose "$($psake.context.currentTaskName) - directory already exists '$releaseDir'."
    }
}

Task Clean -depends Init -requiredVariables releaseDir {
    $startErrorActionPreference = $ErrorActionPreference 
    $ErrorActionPreference = 'SilentlyContinue'
   
    Get-ChildItem -Path $releaseDir | Remove-Item -Recurse -Force -Verbose:$VerbosePreference
        
    Get-ChildItem -Path $TestRootDir -Filter "Test*.xml" -Recurse | Remove-Item -Force -Verbose:$VerbosePreference
    Get-ChildItem -Path $TestRootDir -Filter "Test*.html" -Recurse | Remove-Item -Force -Verbose:$VerbosePreference

    $ErrorActionPreference = $startErrorActionPreference
}

Task Test.Unit -depends Init, Clean, Test.Unit.Before, Test.Unit.Core, Test.Unit.After {
}

Task Test.Unit.Core -requiredVariables TestRootDir, ModuleName, CodeCoverageEnabled, CodeCoverageFiles {
    Invoke-Tests -TestOutputFile $TestOutputFile -TestOutputFormat $TestOutputFormat
    Write-Output "See Test details at: $TestOutputFile"
}

Task Test.Integration -depends Init, Clean, 
     Test.Integration.Before, Test.Integration.Core, Test.Integration.After {
}

Task Test.Integration.Core -requiredVariables TestRootDir, ModuleName, CodeCoverageEnabled, CodeCoverageFiles {
    Invoke-Tests -TestOutputFile $TestOutputFile -TestOutputFormat $TestOutputFormat
    Write-Output "See Test details at: $TestOutputFile"
}

Task Build -depends Init, Clean, Test.Unit, Stage.CoreFiles, 
                    Build.Before, Build.Core, Build.After, Test.Integration {
}

Task Build.Core -requiredVariables ModuleOutDir, SrcRootDir {
    $moduleManifestPath = ( Get-ChildItem -Path $SrcRootDir -Filter "*.psd1" -Recurse).FullName
    $manifestData = Import-PowerShellDataFile -Path $moduleManifestPath
    
    # To Do - manage the PData import in the future
    $manifestData.Remove('PrivateData')
    
    $version = [version]$manifestdata["ModuleVersion"]
    $manifestdata["ModuleVersion"] = "$($version.Major).$($version.Minor).$($version.Build + 1)"

    # Remove the FunctionsToExport key and replace it with data from the module
    if ($manifestData.ContainsKey('FunctionsToExport'))
    {
        $manifestData.Remove('FunctionsToExport')
    }

    # Update the manifest file with the functions exported from the module
    $manifestData['FunctionsToExport'] = $script:exportedCommands
    $manifestdata.Add("Path", "$ModuleOutDir\$ModuleName.psd1")    

    New-ModuleManifest @manifestData

    $manifestdata.Remove("Path")
    # Add the path variable to create the file in the release directory
    $manifestData.add('Path', $moduleManifestPath)
    
    New-ModuleManifest @manifestData    
}

Task Stage.CoreFiles -requiredVariables ModuleOutDir, SrcRootDir {

    if ( -not ( Test-Path -LiteralPath $ModuleOutDir ) ) 
    {
        New-Item $ModuleOutDir -ItemType Directory -Verbose:$VerbosePreference | Out-Null
    }
    else 
    {
        Write-Verbose "$($psake.context.currentTaskName) - directory already exists '$ModuleOutDir'."
    }

    Copy-Item -Path $SrcRootDir\* -Destination $ModuleOutDir -Recurse -Exclude $Exclude -Force -Verbose:$VerbosePreference
}

Task Deploy -depends Init, Clean, Build, Deploy.Before, Deploy.Core, Deploy.After {
}

Task Deploy.Core {
    Copy-Item -Path $ModuleOutDir `
              -Destination $env:USERPROFILE\documents\WindowsPowerShell\Modules `
              -Recurse `
              -Force
}

Task Publish {
    Publish-Module -Name BaselineManagement -NuGetApiKey $NugetApiKey    
}