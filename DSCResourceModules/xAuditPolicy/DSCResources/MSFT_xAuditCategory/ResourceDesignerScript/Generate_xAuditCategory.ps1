
$Name = New-xDscResourceProperty -Name Subcategory -Type String -Attribute Key -Description "The Category to be configured" `
-ValidateSet "Security System Extension","System Integrity","IPsec Driver","Other System Events","Security State Change",
"Logon","Logoff","Account Lockout","IPsec Main Mode","IPsec Quick Mode","IPsec Extended Mode","Special Logon",
"Other Logon/Logoff Events","Network Policy Server","User / Device Claims","Group Membership","File System","Registry",
"Kernel Object","SAM","Certification Services","Application Generated","Handle Manipulation","File Share",
"Filtering Platform Packet Drop","Filtering Platform Connection","Other Object Access Events","Detailed File Share",
"Removable Storage","Central Policy Staging","Non Sensitive Privilege Use","Other Privilege Use Events","Sensitive Privilege Use",
"Process Creation","Process Termination","DPAPI Activity","RPC Events","Plug and Play Events","Authentication Policy Change",
"Authorization Policy Change","MPSSVC Rule-Level Policy Change","Filtering Platform Policy Change","Other Policy Change Events",
"Audit Policy Change","User Account Management","Computer Account Management","Security Group Management",
"Distribution Group Management","Application Group Management","Other Account Management Events","Directory Service Changes",
"Directory Service Replication","Detailed Directory Service Replication","Directory Service Access",
"Kerberos Service Ticket Operations","Other Account Logon Events","Kerberos Authentication Service","Credential Validation"

$Setting = New-xDscResourceProperty -Name AuditType -Type String -Attribute Key -Description "The setting to be configured" `
-ValidateSet "Success","Failure"

$Ensure = New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -Description "Describe the setting state" `
-ValidateSet "Present","Absent"


$AuditPol = @{
    Name = 'MSFT_xAuditCategory'
    Property = $Name,$Setting,$Ensure
    FriendlyName = 'xAuditCategory'
    ModuleName = 'xAuditPolicy'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @AuditPol
