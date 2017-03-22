@{

# Script module or binary module file associated with this manifest.
RootModule = 'GPRegistryPolicyParser.psm1'

#DscResourcesToExport = ''

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '136973e7-64da-494b-bf2d-38d4564bb8f5'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2016 Microsoft. All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

FunctionsToExport = @('Read-PolFile','Read-RegistryPolicies','Add-RegistrySettingsEntry','Add-GPRegistryPolicyFile','Write-RegistryPolicies')
}
