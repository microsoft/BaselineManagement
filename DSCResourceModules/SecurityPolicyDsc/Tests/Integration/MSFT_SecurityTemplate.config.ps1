
# create test user and security template
$userName = "TestUser-" + ([guid]::NewGuid().guid).substring(0,6)
$policy = 'SeTrustedCredManAccessPrivilege'
$directoryEntry = [ADSI]”WinNT://localhost“
$user = $directoryEntry.Create(“User“, $userName)
$user.setpassword('P@ssword1')
$user.SetInfo()

$infTemplate =@"
[Unicode]
Unicode=yes
[Privilege Rights]
$policy = $userName
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

$tempFile = ([system.IO.Path]::GetTempFileName()).Replace('tmp','inf') 
Out-File -InputObject $infTemplate -FilePath $tempFile -Encoding unicode

# Integration Test Config Template Version: 1.0.0

configuration MSFT_SecurityTemplate_config {

    Import-DscResource -ModuleName SecurityPolicyDsc

    node localhost {
    
        SecurityTemplate Integration_Test
        {
            Path = $tempFile
            IsSingleInstance = 'Yes'
        }
    }
}
