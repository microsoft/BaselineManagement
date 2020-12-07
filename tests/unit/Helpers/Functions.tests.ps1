Write-Host "`n"
Write-Host "Paths" -ForegroundColor Green
Write-Host "--------------------"
Write-Host "PSScriptRoot: $PSScriptRoot"
$script:UnitTestRoot = Get-Item $PSScriptRoot | ForEach-Object Parent | ForEach-Object FullName
Write-Host "UnitTestRoot: $script:UnitTestRoot"
$script:SourceRoot = Join-Path -Path (get-item $script:UnitTestRoot | ForEach-Object Parent | ForEach-Object Parent | ForEach-Object FullName) -ChildPath 'src'
Write-Host "SourceRoot: $script:SourceRoot"
$script:TestOutputRoot = Join-Path -Path (get-item $script:UnitTestRoot | ForEach-Object Parent | ForEach-Object FullName) -ChildPath 'output'
Write-Host "TestOutputRoot: $script:TestOutputRoot"
$script:ParsersRoot = "$script:SourceRoot\Parsers" 
Write-Host "ParsersRoot: $script:ParsersRoot"
$script:SampleRoot = "$script:UnitTestRoot\..\Samples"
Write-Host "SampleRoot: $script:SampleRoot"
Write-Host "`n"

$SamplePOL = Join-Path $script:SampleRoot "Registry.Pol"
$SampleGPTemp = Join-Path $script:SampleRoot "gptTmpl.inf"
$SampleAuditCSV = Join-Path $script:SampleRoot "audit.csv"

$Parsers = Get-ChildItem -Filter '*.ps1' -Path $script:ParsersRoot/GPO

Write-Host "Pester version" -ForegroundColor Green
Write-Host "--------------------"
Write-Host "$(Import-Module Pester -RequiredVersion 4.10.0; Get-Module Pester | ForEach-Object Version)"
Write-Host "`n"

Write-Host "Parsers" -ForegroundColor Green
Write-Host "--------------------"
foreach ($p in $Parsers) {Write-Host $p.Name"`t" -NoNewline}
Write-Host "`n"

Write-Host "Available DSC modules" -ForegroundColor Green
Write-Host "--------------------"
foreach ($m in (Get-DSCResource | % ModuleName | Select -Unique)) {
    $r = Get-DSCResource -Module $m | % Name
    Write-Host $m"`t("$r")"
}
Write-Host "`n"

$Functions = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Functions.ps1")
$Enumerations = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Enumerations.ps1")

. $Functions.FullName
. $Enumerations.FullName

Import-Module PSDesiredStateConfiguration -Force

if (!(Test-Path $script:TestOutputRoot)) {
    mkdir $script:TestOutputRoot
}

Describe "DSC String Helper Tests" {
    Context "Write-DSCString" {
        
        # This only works when it feels like it.
        Mock Get-DSCResource -ParameterFilter { $Module -eq "TestModule_01"} -Verifiable { return [psobject]@{Name="TestResource_01";Properties=@(@{Name="Name";IsMandatory=$true}, @{Name="Value";IsMandatory=$true})}}
        Mock Get-DSCResource -ParameterFilter { $Module -eq "TestModule_02"} -Verifiable { return [psobject]@{Name="TestResource_02";Properties=@(@{Name="Name";IsMandatory=$true}, @{Name="Value";IsMandatory=$true})}}

        $CONFIG_Params = @{Configuration=$true;Name="TestConfig"}
        $CONFIG_ModuleParams = @{ModuleName = @("GPRegistryPolicyDSC");ModuleImport=$true}
        $CONFIG_Node = @{Node=$true;Name="localhost"}
        $CONFIG_ResourceParams = @{Resource=$true;Type="RegistryPolicyFile";Name="Test";Parameters=@{Key="HKLM:\SOFTWARE";ValueName = "TestResource";ValueData="Test";ValueType="DWORD" }}
        $CONFIG_Invoke = @{InvokeConfiguration=$true;Name="TestConfig";OutputPath=$(Join-Path -Path "C:\Temp" -ChildPath Output)}
        
        It "Creates a Configuration Open Block" {
            Write-DSCString @CONFIG_Params | Should Match "Configuration $($CONFIG_Params.Name)`n{`n`n`t" 
        }

        $CONFIG_Params.Add("Comment", "Test Comment")
        It "Comments a Configuration Open Block" {
            Write-DSCString @CONFIG_Params | Should Match "<#`n$($CONFIG_Params.Comment)`n#>" 
        }

        It "Creates Module Import Strings" {
            Write-DSCString @CONFIG_ModuleParams | Should Match "(?s)$(($CONFIG_ModuleParams.ModuleName | ForEach-Object {"'$_'"}) -join ", ")"
            #Assert-MockCalled -CommandName Get-DscResource -Times 2
        }

        It "Creates a Resource Block" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?m)$($CONFIG_ResourceParams.Type) '$($CONFIG_ResourceParams.Name)'.*$((($CONFIG_ResourceParams.Parameters.GetEnumerator() | ForEach-Object {"$($_.Key) = '$($_.Value)'"}) -join '|')*4)}"
        }

        It "Parses String Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)'$($CONFIG_ResourceParams.Parameters.ValueData)'"
        }

        [int]$CONFIG_ResourceParams.Parameters.ValueData = 3
        It "Parses Integer Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)$($CONFIG_ResourceParams.Parameters.ValueData)"
        }

        [bool]$CONFIG_ResourceParams.Parameters.ValueData = $True
        It "Parses Boolean Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)\`$$($CONFIG_ResourceParams.Parameters.ValueData)"
        }

        [string[]]$CONFIG_ResourceParams.Parameters.ValueData = "One", "Two", "Three"
        It "Parses Array String Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)$(($CONFIG_ResourceParams.Parameters.ValueData | ForEach-Object {"'$_'"}) -join ", ")"
        }

        [int[]]$CONFIG_ResourceParams.Parameters.ValueData = 1,2,3
        It "Parses Array Integer Values Properly" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)$(($CONFIG_ResourceParams.Parameters.ValueData | ForEach-Object {"$_"}) -join ", ")"
        }

        It "Detects Resource Conflicts" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)<#$($CONFIG_ResourceParams.Type).*}#>" 
        }

        $CONFIG_ResourceParams.Add("CommentOUT", $True)
        It "Comments out Resources when asked" {
            Write-DSCString @CONFIG_ResourceParams | Should Match "(?s)<#$($CONFIG_ResourceParams.Type).*}#>" 
        }

        It "Creates Node Blocks" {
            Write-DSCString @CONFIG_Node | Should Match "Node $($CONFIG_Node.Name)`n`t{`n"
        }

        It "Closes Configuration Blocks" {
            Write-DSCString -CloseConfigurationBlock | Should Match "`n}`n"
        }

        It "Closes Node Blocks" {
              Write-DSCString -CloseNodeBlock | Should Match @"
         RefreshRegistryPolicy 'ActivateClientSideExtension'
         {
             IsSingleInstance = 'Yes'
         }
     }
"@
        }

        It "Creates Invoke Configuration Strings" {
            Write-DSCString @CONFIG_Invoke | Should Match "$($CONFIG_Invoke.Name) -OutputPath '$($CONFIG_Invoke.OutputPath.Replace("\", "\\"))'"
        }
    }
    
    Context "Complete-Configuration" {
        Mock -Verifiable -CommandName Get-PSCallStack { return [psobject]@(@{Command = "None"}, @{Command = "PesterTest"}) }
        $Configuration = @"
Configuration PesterTest
{
    Import-DSCResource -ModuleName GPRegistryPolicyDSC
    Node localhost
    {
        RegistryPolicyFile 'Integration_Test_Disable_SMB1'
        {
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            TargetType = 'ComputerConfiguration'
            ValueName  = 'SMB1'
            ValueData  = 1
            ValueType  = 'DWORD'
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_SMB1'
        {
            IsSingleInstance = 'Yes'
        }
    }
}

PesterTest -OutputPath $($script:TestOutputRoot)
"@
        $Configuration_ERROR = @"
Configuration PesterTest
{
    Import-DSCResource -ModuleName GPRegistryPolicyDSC
    Node localhost
    {
        RegistryPolicyFile 'Integration_Test_Disable_SMB1'
        {
            Key        = 'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            # TargetType
            ValueName  = 'SMB1'
            ValueData  = 1
            ValueType  = 'DWORD'
        }

        RefreshRegistryPolicy 'Integration_Test_RefreshAfter_SMB1'
        {
            IsSingleInstance = 'Yes'
        }
    }
}

PesterTest -OutputPath $($script:TestOutputRoot)
"@
        It "Compiles a Configuration" {
            Complete-Configuration -ConfigString $Configuration -OutputPath $script:TestOutputRoot
            $MOF = (Join-Path -Path $script:TestOutputRoot -ChildPath "localhost.mof")
            $MOF | Should Exist
            Remove-Item $MOF 
        }

        It "Creates Error files on Failure" {
            Try
            {
                Complete-Configuration -ConfigString $Configuration_ERROR -OutputPath $script:TestOutputRoot -ErrorAction SilentlyContinue
            }
            Catch
            {
                continue
                
            }

            $ErrorFile = (Join-Path -Path $script:TestOutputRoot -ChildPath "PesterTest.ps1.error")
            $ErrorFile | Should Exist
            Remove-Item $ErrorFile
        }
    }
}