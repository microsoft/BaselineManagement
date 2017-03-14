#Requires -Version 4.0

# This PS module contains functions for Desired State Configuration (DSC) xAuditPolicy provider. 
# It enables querying, creation, removal and update of Windows advanced audit policies through 
# Get, Set and Test operations on DSC managed nodes.

####################################################################################################
DATA localizedData
{
    ConvertFrom-StringData @'                
        AuditpolNotFound          = (ERROR) auditpol.exe was not found on the system
        RequiredPrivilegeMissing  = (ERROR) A required privilege is not held by the client
        IncorrectParameter        = (ERROR) The parameter is incorrect
        UnknownError              = (ERROR) An unknown error has occured
        ExecuteAuditpolCommand    = Executing 'auditpol.exe {0}'
        GetAuditpolOptionSucceed     = (GET) '{0}'
        GetAuditpolOptionFailed      = (ERROR) getting '{0}'
        SetAuditpolOptionSucceed     = (SET) '{0}' to '{1}'
        SetAuditpolOptionFailed      = (ERROR) setting '{0}' to value '{1}'
        TestAuditpolOptionCorrect    = '{0}' is '{1}'
        TestAuditpolOptionIncorrect  = '{0}' is NOT '{1}'
        GetAuditpolSubcategorySucceed    = (GET) '{0}':'{1}'
        GetAuditPolSubcategoryFailed     = (ERROR) getting '{0}':'{1}'
        SetAuditpolSubcategorySucceed    = (SET) '{0}' audit '{1}' to '{2}'
        SetAuditpolSubcategoryFailed     = (ERROR) setting '{0}' audit '{1}' to '{2}'
        TestAuditpolSubcategoryCorrect   = '{0}':'{1}' is '{2}'
        TestAuditpolSubcategoryIncorrect = '{0}':'{1}' is NOT '{2}' 
        GetAuditpolResourceSACLSucceed      =
        GetAuditpolResourceSACLFailed       = 
        SetAuditpolResourceSACLSucceed      = 
        SetAuditpolResourceSACLFailed       = 
        TestAuditpolResourceSACLCorrect     = 
        TestAuditpolResourceSACLIncorrect   =
        FileNotFound     = (ERROR) File '{0}' not found
        GetCsvSucceed    = (GET) '{0}'
        GetCsvFailed     = (ERROR) getting '{0}'
        TestCsvSucceed   = '{0}' is '{1}'
        TestCsvFailed    = '{0}' is NOT in desired state
        SetCsvSucceed    =  (SET) '{0}' to '{1}'
        SetCsvFailed     = (ERROR) setting '{0}' to value '{1}'
        ExportFailed     = (ERROR) Failed to create temporary file at '{0}'
        ImportFailed     = (ERROR) Failed to import CSV '{0}'
'@
}

$AuditpolOptions = "CrashOnAuditFail","FullPrivilegeAuditing","AuditBaseObjects",
"AuditBaseDirectories"

#region Private Auditpol.exe functions

function Invoke_AuditPol
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CommandToExecute 
    )

    Write-Debug ($localizedData.ExecuteAuditpolCommand -f $CommandToExecute)

    try
    {
        $return = Invoke-Expression -Command "$env:SystemRoot\System32\auditpol.exe $CommandToExecute" 2>&1
        Write-Verbose $CommandToExecute
        
        if($LASTEXITCODE -eq 87)
        {
            Throw New-Object System.ArgumentException $localizedData.IncorrectParameter
        }
        $return
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        # catch error if the auditpol command is not found on the system
        Write-Error $localizedData.AuditpolNotFound 
    }
    catch [System.ArgumentException]
    {
        $localizedData.IncorrectParameter 
    }
    catch
    {
        $localizedData.UnknownError
    }
}

function Get_AuditpolSubcommand
{
    [CmdletBinding(DefaultParameterSetName="Subcategory")]
    param
    (
        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [ValidateSet("Security System Extension","System Integrity","IPsec Driver",
        "Other System Events","Security State Change","Logon","Logoff","Account Lockout",
        "IPsec Main Mode","IPsec Quick Mode","IPsec Extended Mode","Special Logon",
        "Other Logon/Logoff Events","Network Policy Server","User / Device Claims",
        "Group Membership","File System","Registry","Kernel Object","SAM","Certification Services",
        "Application Generated","Handle Manipulation","File Share","Filtering Platform Packet Drop",
        "Filtering Platform Connection","Other Object Access Events","Detailed File Share",
        "Removable Storage","Central Policy Staging","Non Sensitive Privilege Use",
        "Other Privilege Use Events","Sensitive Privilege Use","Process Creation",
        "Process Termination","DPAPI Activity","RPC Events","Plug and Play Events",
        "Authentication Policy Change","Authorization Policy Change",
        "MPSSVC Rule-Level Policy Change","Filtering Platform Policy Change",
        "Other Policy Change Events","Audit Policy Change","User Account Management",
        "Computer Account Management","Security Group Management","Distribution Group Management",
        "Application Group Management","Other Account Management Events",
        "Directory Service Changes","Directory Service Replication",
        "Detailed Directory Service Replication","Directory Service Access",
        "Kerberos Service Ticket Operations","Other Account Logon Events",
        "Kerberos Authentication Service","Credential Validation")]
        [System.String]
        $SubCategory,

        [parameter(Mandatory = $true,
                   ParameterSetName="ResourceSACL")]
        [ValidateSet("File","Key")]
        [System.String]
        $ResourceSACLType,

        [parameter(Mandatory = $true,
                   ParameterSetName="ResourceSACL")]
        [System.String]
        $User,

        [parameter(Mandatory = $true,
                   ParameterSetName="Option")]
        [ValidateSet("CrashOnAuditFail","FullPrivilegeAuditing",
        "AuditBaseObjects","AuditBaseDirectories")]
        [System.String]
        $Option
    )

    switch ($PSCmdlet.ParameterSetName) 
    {
        "SubCategory"  
        {
            (Invoke_Auditpol -CommandToExecute "/get /subcategory:""$SubCategory"" /r" | 
             Select-String -Pattern $env:ComputerName)
            
            Break
        }

        "ResourceSACL"  
        {
            # the /type switch is case sensitive, so it needs to be validated 
            # and corrected before use. 
            switch($Type)
            {
                {$ResourceSACLType -eq "file"} {$type="File"}
                {$ResourceSACLType -eq "key" } {$type="Key" }
            }

            $ResourceSACL = Invoke_Auditpol `
                -CommandToExecute "/resourcesacl /Type:$type /User:$User /view"

            # 
            If($ResourceSACL -like 'Currently, there is no global SACL*')
            {
                $null
            }
            else
            {
                $ResourceSACL
            }

            Break
        }

        "Option"  
        {
            # Update the command to retrieve the requested option
            # The second line is all that needs to be returned
            # Below is a sample of the raw output from auditpol

            # Option Name                             Value
            # AuditBaseObjects                        Disabled <- return this line only

            (Invoke_Auditpol -CommandToExecute "/get /option:$Option")[1]
            
            Break
        }
    }
}

function Set_AuditpolSubcommand
{
    [CmdletBinding(SupportsShouldProcess=$true,
                   DefaultParameterSetName="SubCategory")]
    param
    (
        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [ValidateSet("Security System Extension","System Integrity","IPsec Driver",
        "Other System Events","Security State Change","Logon","Logoff","Account Lockout",
        "IPsec Main Mode","IPsec Quick Mode","IPsec Extended Mode","Special Logon",
        "Other Logon/Logoff Events","Network Policy Server","User / Device Claims",
        "Group Membership","File System","Registry","Kernel Object","SAM","Certification Services",
        "Application Generated","Handle Manipulation","File Share","Filtering Platform Packet Drop",
        "Filtering Platform Connection","Other Object Access Events","Detailed File Share",
        "Removable Storage","Central Policy Staging","Non Sensitive Privilege Use",
        "Other Privilege Use Events","Sensitive Privilege Use","Process Creation",
        "Process Termination","DPAPI Activity","RPC Events","Plug and Play Events",
        "Authentication Policy Change","Authorization Policy Change",
        "MPSSVC Rule-Level Policy Change","Filtering Platform Policy Change",
        "Other Policy Change Events","Audit Policy Change","User Account Management",
        "Computer Account Management","Security Group Management","Distribution Group Management",
        "Application Group Management","Other Account Management Events",
        "Directory Service Changes","Directory Service Replication",
        "Detailed Directory Service Replication","Directory Service Access",
        "Kerberos Service Ticket Operations","Other Account Logon Events",
        "Kerberos Authentication Service","Credential Validation")]
        [System.String]
        $SubCategory,

        [parameter(Mandatory = $true,
                   ParameterSetName="ResourceSACL")]
        [ValidateSet("File","Key")]
        [System.String]
        $ResourceSACLType,

        [parameter(Mandatory = $true,
                   ParameterSetName="ResourceSACL")]
        [ValidateSet("File","Key")]
        [System.String]
        $ResourceSACLUser,

        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [parameter(ParameterSetName="ResourceSACL")]
        [ValidateSet("Success","Failure", "SuccessAndFailure", "NoAuditing")]
        [System.String]
        $AuditFlag,

        [parameter(Mandatory = $true,
                   ParameterSetName="Option")]
        [ValidateSet("CrashOnAuditFail","FullPrivilegeAuditing","AuditBaseObjects",
        "AuditBaseDirectories")]
        [System.String]
        $Name,

        [parameter(Mandatory = $true,
                   ParameterSetName="Option")]
        [ValidateSet("Enabled","Disabled")]
        [System.String]
        $Value,
        
        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [parameter(ParameterSetName="ResourceSACL")]
        [System.String]
        $Ensure
    )

    switch ($PSCmdlet.ParameterSetName) 
    {
        "Subcategory"
        { 
            # translate $ensure=present to enable and $ensure=absent to disable
            $auditState = @{"Present"="enable";"Absent"="disable"}
            switch -regex ($AuditFlag)
            {
                "Success"
                {
                    $commandToExecute = [string]('/set /subcategory:"' + $SubCategory + '" /success:' + $($auditState[$Ensure]))
                }
                
                "Failure"
                {
                    $commandToExecute = [string]('/set /subcategory:"' + $SubCategory + '" /failure:' + $($auditState[$Ensure]))
                }

                "NoAuditing"
                {
                    $commandToExecute = [string]('/set /subcategory:"' +$SubCategory + '" /success:' + $($auditState["Absent"]) + ' /failure:' + $($auditState["Absent"])) 
                }

                Default { Write-Error "$_ is not a valid AuditFlag" }
            }
            
            if($PSCmdlet.ShouldProcess($Option))
            {
                Invoke_Auditpol -CommandToExecute $commandToExecute
            }
            else
            {
                # Return a sting when the -whatif switch is set 
                "Set $SubCategory $AuditFlag to $($auditState[$Ensure])"
            }
            
            Break
        }

        "ResourceSACL"  
        {
            # the /type switch is case sensitive and it needs to be validated before use. 
            switch($Type)
            {
                {$ResourceSACLType -eq "file"} {$type="File";Break}
                {$ResourceSACLType -eq "key" } {$type="Key" ;Break}
            }

            switch($flags)
            {
                {$AuditFlag -eq "Success" }           {$flag="/Success "        ;Break}
                {$AuditFlag -eq "Failure" }           {$flag="/Failure "        ;Break}
                {$AuditFlag -eq "SuccessAndFailure" } {$flag="/Success /Failure";Break}
                {$AuditFlag -eq "No Auditing" } { $flag = "/remove"; Break }
            }

            $ResourceSACL = Invoke_Auditpol `
                -CommandToExecute "/resourcesacl /Type:$type /User:$user $Flag"

            If($ResourceSACL -eq 'Currently, there is no global SACL for this resource type.')
            {
                $null
            }
            else
            {
                $ResourceSACL
            }
            Break
        }

        "Option"  
        {
            # the output text of auditpol is in simple past tense, but the input is in simple 
            # present tense the hashtable corrects the tense for the input.  
            $valueHashTable = @{"Enabled"="enable";"Disabled"="disable"}

            if($PSCmdlet.ShouldProcess($Name))
            {
                Invoke_Auditpol `
                    -CommandToExecute "/set /option:$Name /value:$($valueHashTable[1])"
            }
            else
            {
                # Return a sting when the -whatif switch is set 
                "Set $Name to $Value"
            }

            Break
        }
    }
}

#endregion

#region Public Category functions

<#
    .SYNOPSIS 
    Gets the audit flag state for a specifc subcategory. 

    .PARAMETER SubCategory 
    The name of the subcategory to get the audit flags from.
    
    .EXAMPLE
    Get-AuditCategory -SubCategory 'Logon'
#>
function Get-AuditCategory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $SubCategory
    )
 
    $split = (Get_AuditpolSubcommand @PSBoundParameters) -split ","

    $subcategoryObject = New-Object PSObject
    $subcategoryObject | Add-Member -MemberType NoteProperty -Name Name -Value $split[2]
    # remove the spaces from 'Success and Failure' to prevent any wierd sting problems later. 
    $subcategoryObject | Add-Member -MemberType NoteProperty -Name AuditFlag `
                                    -Value ($split[4] -replace " ","")
    return $subcategoryObject
}

<#
    .SYNOPSIS 
    Sets the audit flag state for a specifc subcategory. 

    .PARAMETER SubCategory 
    The name of the subcategory to set the audit flag on.

    .PARAMETER AuditFlag 
    The name of the Auditflag to set.
    
    .PARAMETER Ensure 
    The name of the subcategory to get the audit flags from.
        
    .EXAMPLE
    Set-AuditCategory -SubCategory 'Logon'
#>
function Set-AuditCategory
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $SubCategory,

        [parameter(Mandatory = $true)]
        [System.String]
        $AuditFlag,

        [parameter(Mandatory = $true)]
        [System.String]
        $Ensure
    )
 
    Set_AuditpolSubcommand @PSBoundParameters
}

<#
    .SYNOPSIS 
    Helper function to use SecurityCmdlet modules if present. If not, go through AuditPol.exe.

    .PARAMETER Action 
    The action to take, either Import or Export. Import will clear existing policy before writing.

    .PARAMETER Path 
    The path to a CSV file to either create or import.
        
    .EXAMPLE
    Invoke-SecurityCmdlet -Action Import -Path .\test.csv
#>
function Invoke-SecurityCmdlet
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Import","Export")]
        [System.String]
        $Action,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path 
    )
    #test if cmdlet is present. if not, use auditpol directly.
    if (!(Get-Module -ListAvailable -Name "SecurityCmdlets"))
    {

        if ($Action -eq "Import")
        {
            #Ignore output - causes return values we don't want
            Invoke_AuditPol "/restore /file:$path" | Out-Null
        }
        elseif ($Action -eq "Export")
        {

            Invoke_AuditPol "/backup /file:$path" | Out-Null
        }
    }
    else
    {
        #cmdlet is present, see if it's loaded, and start using it
        if (! (Get-Module SecurityCmdlets)  )
        {

            Import-Module SecurityCmdlets
        }
        if ($Action -eq "Import")
        {
            #Ignore output - causes return values we don't want
            Restore-AuditPolicy $Path | Out-Null
        }
        elseif ($Action -eq "Export")
        {
            #no force option on Backup, manually check for file and delete it so we can write back again
            if (Test-Path $path)
            {
                Remove-Item $path -force
            }
            Backup-AuditPolicy $Path | Out-Null
        }

    }
}

#endregion

#region Public Option functions

function Get-AuditOption
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name
    )
 
    # Get_AuditpolStrings returns a single string with the Option and value on a single line
    # so we simply return the matched value. 
    Switch (Get_AuditpolSubcommand -Option $Name)
    {
        {$_ -match "Disabled"} {$auditpolStrings = 'Disabled'}
        {$_ -match "Enabled" } {$auditpolStrings = 'Enabled' }
    }

    $auditpolStrings
}

function Set-AuditOption
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$true)]
        [System.String]
        $Value
    )
 
    Set_AuditpolSubcommand @PSBoundParameters
}

#endregion

# all internal functions are named with "_" vs. "-"
Export-ModuleMember -Function *-* -Variable localizedData
