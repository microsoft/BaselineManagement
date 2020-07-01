$script:TestSourceRoot = "$PsScriptRoot"
$script:UnitTestRoot = (Get-ParentItem -Path $script:TestSourceRoot -Filter "unit" -Recurse -Directory).FullName
$script:SourceRoot = (Get-ParentItem -Path $script:TestSourceRoot -Filter "src" -Recurse -Directory).FullName
$script:ParsersRoot = "$script:SourceRoot\Parsers" 
$script:SampleRoot = "$script:UnitTestRoot\Samples"

$Functions = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Functions.ps1")
$Enumerations = Get-Item -Path (Join-Path -Path $script:SourceRoot -ChildPath "Helpers\Enumerations.ps1")

. $Functions.FullName
. $Enumerations.FullName

Import-Module PSDscResources -Force

Describe "DSC String Helper Tests" {
    Context "Write-DSCString" {
        
        # This only works when it feels like it.
        Mock Get-DSCResource -ParameterFilter { $Module -eq "TestModule_01"} -Verifiable { return [psobject]@{Name="TestResource_01";Properties=@(@{Name="Name";IsMandatory=$true}, @{Name="Value";IsMandatory=$true})}}
        Mock Get-DSCResource -ParameterFilter { $Module -eq "TestModule_02"} -Verifiable { return [psobject]@{Name="TestResource_02";Properties=@(@{Name="Name";IsMandatory=$true}, @{Name="Value";IsMandatory=$true})}}

        $CONFIG_Params = @{Configuration=$true;Name="TestConfig"}
        $CONFIG_ModuleParams = @{ModuleName = @("PSDscResources");ModuleImport=$true}
        $CONFIG_Node = @{Node=$true;Name="localhost"}
        $CONFIG_ResourceParams = @{Resource=$true;Type="Registry";Name="Test";Parameters=@{Key="HKLM:\SOFTWARE";ValueName = "TestResource";ValueData="Test";ValueType="DWORD" }}
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
            Write-DSCString -CloseNodeBlock | Should Match "`t}"
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
    Import-DSCResource -ModuleName PSDscResources
    Node localhost
    {
        Service Spooler
        {
            Name = 'Spooler'
            State = 'Running'
        }
    }
}

PesterTest -OutputPath $($script:TestSourceRoot)
"@
        $Configuration_ERROR = @"
Configuration PesterTest
{
    Import-DSCResource -ModuleName PSDscResources
    Node localhost
    {
        Service Spooler
        {
            State = 'Running'
        }
    }
}

PesterTest -OutputPath $($script:TestSourceRoot)
"@
        It "Compiles a Configuration" {
            Complete-Configuration -ConfigString $Configuration -OutputPath $script:TestSourceRoot
            $MOF = (Join-Path -Path $script:TestSourceRoot -ChildPath "localhost.mof")
            $MOF | Should Exist
            Remove-Item $MOF 
        }

        It "Creates Error files on Failure" {
            Try
            {
                Complete-Configuration -ConfigString $Configuration_ERROR -OutputPath $script:TestSourceRoot -ErrorAction SilentlyContinue
            }
            Catch
            {
                continue
                
            }

            $ErrorFile = (Join-Path -Path $script:TestSourceRoot -ChildPath "PesterTest.ps1.error")
            $ErrorFile | Should Exist
            Remove-Item $ErrorFile
        }
    }
}
