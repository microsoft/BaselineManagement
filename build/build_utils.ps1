<#
 .SYNOPSIS
Executes Pester tests using Psake varaibles.   
#>
function Invoke-Tests
{
    param
    (
        [Parameter()]
        [string]$TestOutputFile,

        [Parameter()]
        [string]$TestOutputFormat
    )

    Write-host $pwd
    if ( -not ( Get-Module Pester -ListAvailable ) ) 
    {
        "Pester module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    Import-Module Pester

    try 
    {
        if ($TestOutputFile) 
        {
            $testing = @{
                OutputFile   = $TestOutputFile
                OutputFormat = $TestOutputFormat
                PassThru     = $true
                Verbose      = $VerbosePreference
            }
        }
        else 
        {
            $testing = @{
                PassThru     = $true
                Verbose      = $VerbosePreference
            }
        }

        # To control the Pester code coverage, a boolean $CodeCoverageEnabled is used.
        if ($CodeCoverageEnabled) 
        {
            $testing.CodeCoverage = $CodeCoverageFiles
        }

        $testResult = Invoke-Pester @testing

        if ($testResult.FailedCount -ne 0)
        {
            Write-Error "Error Pester: $($testResult.FailedCount) tests failed, build cannot continue."
        }

        # This assert from Psake does not trigger 
        #Assert -conditionToCheck (
        #    $testResult.FailedCount -eq 0
        #) -failureMessage "One or more Pester tests failed, build cannot continue."

        if ($CodeCoverageEnabled) 
        {
            $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted /
                                  $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)
            "Pester code coverage on specified files: ${testCoverage}%"
        }

        if (Get-Module Format-Pester -ListAvailable) 
        {
            $outputHtml = $TestOutputFile.Replace(".xml", "")
            "Format-Pester is installed. Creating Output HTML: $outputHTML"
            $basename = Split-Path -Path $TestOutputFile -Leaf
            $testResult | Format-Pester -Format HTML -Path $pwd -BaseFileName $basename
        }
    }
    finally 
    {
        Remove-Module $ModuleName -ErrorAction SilentlyContinue
    }
}

