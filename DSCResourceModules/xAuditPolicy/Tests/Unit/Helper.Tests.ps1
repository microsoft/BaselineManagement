#requires -RunAsAdministrator

# get the root path of the resourse
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) 

# get the module name to import
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".tests.ps1", ".psm1")

Import-Module "$moduleRoot\DSCResources\$sut" -Force

#region Generate data

# The auditpol utility outputs the list of categories and subcategories in a couple 
# of different ways and formats. Using the /list flag only returns the categories 
# without the associated audit setting, so it is easier to filter on.
function GetauditpolCategories
{
    $auditpol = auditpol /list /subcategory:*
    $Categories = @()
    $SubCategories = @()
    $auditpol | Where-Object {$_ -notlike 'Category/Subcategory*'} | ForEach-Object `
    {
        # the categories do not have any space in front of them, but the subcategories do.
        if($_ -notlike " *")
        {
            $Categories += $_.Trim()
        }
        else
        {
            $SubCategories += $_.trim()
        }
    } 
    $Categories, $SubCategories
} 

$Categories, $SubCategories = GetauditpolCategories


# list of auditpol options that can be set
$Options = "CrashOnAuditFail","FullPrivilegeAuditing","AuditBaseObjects","AuditBaseDirectories"

#endregion

Describe -Tags Setup, Prereq 'Prereq' {
# There are several dependencies for both Pester and auditpol resource that need to be validated.

    It "Checks if the tests are running as admin" {
        # the tests need to run as admin to have access to the auditpol data
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator") | Should Be $true
    }

    It "Checks auditpol.exe exists in System32  " {
        # if the auditpol is not located on the system, the entire module will fail
        Test-Path "$env:SystemRoot\system32\auditpol.exe" | Should Be $true
    }
}

Describe -Tags Setup 'auditpol.exe output' {
# verify the raw auditpol output format has not changed across different OS versions and types.
    
    It "Checks auditpol default return with no parameters      " {
        (auditpol.exe)[0] | should BeExactly 'Usage: AuditPol command [<sub-command><options>]'
    }

    It "Checks auditpol CSV header format with the /r switch   " {
        (auditpol.exe /get /subcategory:logon /r)[0] | should BeExactly "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting"
    }

    # loop through the raw output of every category option to validate the auditpol /category subcommand
    Foreach($Category in $Categories) 
    {
        Context "Category: $Category" {
        
            $auditpolCategory = auditpol.exe /get /category:$Category /r
          
            It "Checks auditpol category returns empty string on line 1 " {
                $auditpolCategory[1] | should Be ""
            }

            It "Checks auditpol category returns first entry  on line 2 " {
                # the auditpol /r output starts with the computer name on each entry
                $auditpolCategory[2] | should Match "$env:ComputerName"
            }
        }
    }

    # loop through the filtered output of every category option to validate the auditpol /category subcommand
    Foreach($Category in $Categories) 
    {
        Context "Category: $Category Filtered 'Select-String -Pattern `$env:ComputerName'" {
        
            # Reuse the same command as the raw output context, only this time filter out the entries.
            # this is to verify the row indexing is not broken in later formatting actions
            $auditpolCategory = auditpol.exe /get /category:$Category /r | Select-String -Pattern $env:ComputerName
            $auditpolCategoryCount = ($auditpolCategory | Measure-Object).Count
        
            It "Checks auditpol category returns $auditpolCategoryCount items  " { 
                # The header row has been stripped, so greater than 1 is required to account for multiple subcategories
                $auditpolCategoryCount | should BeGreaterThan 1
            }

            # loop through the subcategories returned by the current category that was queried
            for ($i=0;$i -lt $auditpolCategoryCount;$i++)
            {
                It "Checks auditpol category returns entry on line $i " {
                    # Verify that each filtered row that is returned, is in the expected format 
                    $auditpolCategory[$i] | should Match "$env:ComputerName,System,"                   # <- Add more specific regexto account for positional GUID
                }
            }

            It "Checks auditpol category returns `$null on line $auditpolCategoryCount " {
                # with a zero base, the count of the subcategories should index to the end of the list
                $auditpolCategory[$auditpolCategoryCount] | should BeNullOrEmpty
            }
        }
    }

    # loop through the raw output of every subcategory to validate the auditpol /subcategory subcommand
    Foreach($Subcategory in $Subcategories) 
    {
        Context "Subcategory: $Subcategory" {

            $auditpolSubcategory = auditpol.exe /get /subcategory:$Subcategory /r

            It "Checks auditpol Subcategory returns empty string on line 1 " {
                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[1] | should BeNullOrEmpty
            }
        
            It "Checks auditpol Subcategory returns first entry  on line 2 " {
                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[2] | should Match "$env:ComputerName"
            }

            # add a regex for the entire string format to get an exact answer
        }
    }

    # loop through the filtered output of every subcategory to validate the auditpol /subcategory subcommand
    Foreach($Subcategory in $Subcategories) 
    {
        Context "Subcategory: $Subcategory Filtered 'Select-String -Pattern `$env:ComputerName'" {
        
            # Reuse the same command as the raw output context, only this time filter out the entries.
            # this is to verify the row indexing is not broken in the formatting function
            $auditpolSubcategory = auditpol.exe /get /subcategory:$Subcategory /r | Select-String -Pattern $env:ComputerName

            It "Checks auditpol Subcategory returns one item         " {
                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                ($auditpolSubcategory | Measure-Object).Count | should Be 1
            }

            It "Checks auditpol Subcategory returns entry on line 0  " {
                    # Verify that each filtered row that is returned, is in the expected format 
                    $auditpolSubcategory[0] | should Match "$env:ComputerName,System,"                   # <- Add more specific regex
           }

            It "Checks auditpol Subcategory returns `$null on line 1  " {
                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[1]| should BeNullOrEmpty
            }
        }
    }

    Foreach($type in "File","Key")
    {
        # If a resourceSACL is not applied to the system, a specific message is returned 
        $NoGlobalSACL = "Currently, there is no global SACL for this resource type."

        Context "ResourceSACL $type" {
    
            $auditpol = auditpol.exe /resourcesacl /Type:$type /view

            # The first line can be the string Entry or the “no global salc” string 
            It "Checks line 0  for the string 'Entry:' or '$NoGlobalSACL'" {
                $auditpol[0] | Should Match "Entry:|$NoGlobalSACL"
            }
            # The remaining (even) lines can be the string ResourceSACL properties or null since 
            # the no sacl string is a single line
            It "Checks line 2  for the string 'Resource Type:' or 'null'" {
                $auditpol[2] | Should Match "Resource Type:|$"
            }
    
            It "Checks line 4  for the string 'User:' or 'null'" {
                $auditpol[4] | Should Match "User:|$"
            }

            It "Checks line 6  for the string 'Flags:' or 'null'" {
                $auditpol[6] | Should Match "Flags:|$"
            }

            It "Checks line 8  for the string 'Condition:' or 'null'" {
                $auditpol[8] | Should Match "Condition:|$"
            }

            It "Checks line 10 for the string 'Accesses:' or 'null'" {
                $auditpol[10] | Should Match "Accesses:|$"
            }
        }


        Context "ResourceSACL $type Filtered 'Where-Object {`$_ -ne """"}'" {
    
            # Reuse the same command as the raw output context, only this time filter out the blank lines.
            # The Select-String won't work as well here, because each line is different and we just need to 
            # remove the empty rows. This is to verify the row indexing is not broken in the formatting function 
            $auditpol = (auditpol.exe /resourcesacl /Type:$type /view) | Where-Object {$_ -ne ""}

            # The first line can be the string Entry or the “no global salc” string 
            It "Checks line 0 for the string 'Entry:' or '$NoGlobalSACL'" {
                $auditpol[0] | Should Match "Entry:|$NoGlobalSACL"
            }

            # The remaining lines can be the string ResourceSACL properties or null since 
            # the no sacl string is a single line
            It "Checks line 1 for the string 'Resource Type:' or 'null'" {
                $auditpol[1] | Should Match "Resource Type:|$"
            }
    
            It "Checks line 2 for the string 'User:' or 'null'" {
                $auditpol[2] | Should Match "User:|$"
            }

            It "Checks line 3 for the string 'Flags:' or 'null'" {
                $auditpol[3] | Should Match "Flags:|$"
            }

            It "Checks line 4 for the string 'Condition:' or 'null'" {
                $auditpol[4] | Should Match "Condition:|$"
            }

            It "Checks line 5 for the string 'Accesses:' or 'null'" {
                $auditpol[5] | Should Match "Accesses:|$"
            }
        }
    }
}

InModuleScope Helper {
# The helper module contains several private functions that need to be tested

    Describe -Tags Private, Invoke_Auditpol "Private function Invoke_Auditpol" {

        It " an IncorrectParameter message is returned when invalid input is provided" {
            Invoke_Auditpol -Command "/bad" | Should Be $localizedData.IncorrectParameter 
        }

        It " -Command '/get /category:system'' returns 'System audit policy'" {
            (Invoke_Auditpol -Command "/get /category:system")[0] | Should BeExactly "System audit policy" 
        }
    }

    Describe -Tags Private, Get, AuditpolSubcommand, Unit "Private function Get_AuditpolSubcommand unit tests" {

        Context "'Option' parameterset return object" {
            
            # create a string array to mimic the auditpol output
            [string[]]$returnString =  "Option Name                             Value"
                      $returnString += "CrashonAuditFail                        Disabled"

            Mock Invoke_Auditpol { return $returnString }
            
            [string]$auditpolString = Get_AuditpolSubcommand -Option CrashOnAuditFail 

            It " is a single string:" {
                $isSingleString = ($auditpolString.GetType().Name -eq 'string') -and (($auditpolString | Measure-Object).Count -eq [int]1)

                $isSingleString | Should Be $true
            }

            It " that is passed through unaltered" {
               $theSecondStringInTheArray = $returnString[1]

               $auditpolString | Should Be $theSecondStringInTheArray
            }
        }
        
        Context "'Category' parameterset return object" { 
            
            # generte an array of strings to simulate the auditpol output
            [string[]]$returnString =  "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting"
                      $returnString += "$null"
                      $returnString += "$env:COMPUTERNAME,System,Logon,{0CCE9215-69AE-11D9-BED3-505054503030},Success and Failure,"
            
            Mock Invoke_Auditpol { return $returnString }

            # call the function in test
            [string]$AuditpolSubcommandString = Get_AuditpolSubcommand -Subcategory "logon"
        
            It " is a single string " {
                $isSingleString = ( $AuditpolSubcommandString.GetType().Name -eq 'string' ) -and ( ($AuditpolSubcommandString | Measure-Object).Count -eq [int]1 )

                $isSingleString | Should Be $true
            }

            It " that is passed through unaltered" {
                [string]$theThirdStringInTheArray = $returnString[2]

                $AuditpolSubcommandString | Should Be $theThirdStringInTheArray
            }
        }

       # Context "ResourceSACL parameterset return object is" { }

    }

    Describe -Tags Private, Get, AuditpolSubcommand, Integration "Private function Get_AuditpolSubcommand integration tests" {  
    
        Context "'Option' parameterset with option " {

            It " 'Invalid' throws an error" {
                # verify that invalid input generates an error
                {Get_AuditpolSubcommand -Option Invalid} | should Throw 
            }

            # $AuditpolOptions is imported from the helper module

            Foreach($AuditpolOption in $AuditpolOptions)
            {
                It " '$AuditpolOption' returns '$AuditpolOption' and (Enabled or Disabled)" {
                    # The output of this function looks like "AuditBaseObjects                        Enabled"
                    # The regex matches the option name exactly and then looks ahead for Disabled or Enabled
                    Get_AuditpolSubcommand -Option $AuditpolOption | Should match "$AuditpolOption(?=.*Disabled)|(?=.*Enabled)"
                }
            }
        }
        
        Context "'Category' parameterset with Subcategory " { 
            
            It " 'Invalid' throws an error" {
                # verify that invalid input generates an error
                {Get_AuditpolSubcommand -Subcategory Invalid} | should Throw 
            }

            $auditpolString = Get_AuditpolSubcommand -Subcategory "logon"

            It " a string that matches 'Machine Name,,Subcategory,Subcategory GUID,Audit Flag(s),' format" {
                $auditpolString | Should Match "$env:COMPUTERNAME,System,Logon,{0CCE9215-69AE-11D9-BED3-505054503030},(Success)|(Failure)|(Success and Failure)|(No Auditing),"
            }
        }

        # Context "'ResourceSACL' parameterset" { }


    
    }

    Describe -Tags Private, Set, AuditpolSubcommand, Unit 'Private function Set_AuditpolSubcommand unit tests' {   }

    Describe -Tags Private, Set, AuditpolSubcommand, Integration 'Private function Set_AuditpolSubcommand integration tests' {   
    
        Mock Set_AuditpolSubcommand { return }

    }
}

Describe -Tags Get, Category, Unit 'Get-AuditCategory unit tests' {

    # the return format is ComputerName,System,Subcategory,GUID,AuditFlags
    Mock Get_AuditpolSubcommand { return "$env:ComputerName,system,Logon,[GUID],Sucess"  } -ModuleName Helper

    $AuditCategory = Get-AuditCategory -SubCategory logon

    It "Should return a PSCustomObject" {
        $isPSCustomObject = $AuditCategory.GetType().Name -eq 'PSCustomObject'
        
        $isPSCustomObject | Should Be $true
    }

    It " with a Name property" {
        $NameProperty = ($AuditCategory | Get-Member -MemberType NoteProperty -Name Name).Name

        $NameProperty | Should Be "Name"
    }

    It " with a AuditFlag property" {
        $NameProperty = ($AuditCategory | Get-Member -MemberType NoteProperty -Name AuditFlag).Name

        $NameProperty | Should Be "AuditFlag"
    }
}

Describe -Tags Get, Category, Integration 'Get-AuditCategory integration tests' {

}

Describe -Tags Set, Category, Unit 'Set-AuditCategory unit tests' {

    Mock Set_AuditpolSubcommand { return } -ModuleName Helper
}

Describe -Tags Set, Category, Integration 'Set-AuditCategory integration test' {

}

Describe -Tags Get, Option, Unit 'Get-AuditOption unit tests' { 

    Mock Get_AuditpolSubcommand { return } -ModuleName Helper
}

Describe -Tags Get, Option, Integration 'Get-AuditOption integration tests' {
    
    # using the list of options generated at the begining of the script
    foreach($Option in $Options)
    {
        # verify that Get-AuditPol -Option returns exactly "Enabled" or "Disabled"
        It "Verfies the option $Option is a valid" {
            Get-AuditOption -Name $Option | should Match "Enabled|Disabled"
        }
    }

    It "Verfies the option Invalid_Option throws an error" {
        # verify that Get-AuditPol -Option validates parameter input
            {Get-AuditOption Invalid_Option} | should Throw
    }

}

Describe -Tags Set, Option, Unit 'Set-AuditOption unit tests' { 

    Mock Get_AuditpolSubcommand { return } -ModuleName Helper
    
}

Describe -Tags Set, Option, Integration 'Set-AuditOption integration tests' {

    $value = "Enabled"

    Foreach($Option in $Options)
    {
        It "Tests 'Set-Auditpol -Option $Option -Value $value -whatif'" {
            (Set-AuditOption -Name $Option -Value $value -whatif) | Should Be  "Set $Option to $value"
        }
    }
}