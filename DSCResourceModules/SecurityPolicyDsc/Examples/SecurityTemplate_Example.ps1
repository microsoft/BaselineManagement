Configuration CompareInfs
{
    Import-DscResource -ModuleName SecurityPolicyDsc

    node localhost
    {
        SecurityTemplate TrustedCredentialAccess
        {
            Path = "C:\scratch\SecurityPolicyBackup.inf"
            IsSingleInstance = 'Yes'
        }
    }
}

CompareInfs -OutputPath C:\DSC
Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force
