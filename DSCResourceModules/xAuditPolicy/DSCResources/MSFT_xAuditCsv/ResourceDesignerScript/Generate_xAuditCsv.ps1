$CsvPath = New-xDscResourceProperty -Name CsvPath -Type String -Attribute "Key" -Description "Path to a .CSV backup of Auditing settings"
$Force = New-xDscResourceProperty -Name Force -Type Boolean -Attribute "Write" -Description "Only allow settings defined in the desired state. Defaults to False"
$AuditPol = @{
    Name = 'MSFT_xAuditCsv'
    Property = $CsvPath, $Force
    FriendlyName = 'xAuditCsv'
    ModuleName = 'xAuditPolicy'
    Path = 'C:\git\'
}

New-xDscResource @AuditPol
