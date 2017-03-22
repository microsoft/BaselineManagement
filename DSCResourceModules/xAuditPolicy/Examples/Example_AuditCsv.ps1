
Configuration AuditPolicy
{
    Import-DscResource -ModuleName xAuditPolicy
    node localhost
    {
        xAuditCsv auditPolicy
        {
            CsvPath = "C:\Program Files\WindowsPowershell\Modules\AuditPolicy\audit.csv"
        }
    
    }
}
AuditPolicy -outputpath 'C:\Program Files\windowspowershell\Modules\auditpolicy\'

#Invoke-DscResource xAuditCsv -Method Set -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\audit.csv"} -ModuleName xAuditPolicy -verbose

Start-DscConfiguration -Wait -verbose -path .\AuditPolicy -force
