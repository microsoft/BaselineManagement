cls

Configuration AuditPolicy
{
    Import-DscResource -ModuleName xAuditPolicy

    xAuditOption AuditBaseDirectories
    {
        Name  = 'AuditBaseDirectories'
        Value = 'Enabled'
    }

    xAuditCategory LogonSuccess
    {
        Subcategory = 'Logon'
        AuditFlag   = 'Success'
        Ensure      = 'Absent' 
    } 

    xAuditCategory LogonFailure
    {
        Subcategory = 'Logon'
        AuditFlag   = 'Failure'
        Ensure      = 'Present' 
    } 
}


AuditPolicy

# Test-DscConfiguration -Path .\AuditPolicy

# Get-DscConfiguration

# Start-DscConfiguration -Path .\AuditPolicy -Wait -Verbose -Force