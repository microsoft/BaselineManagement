@{

# Script module or binary module file associated with this manifest.
RootModule = 'GPRegistryPolicyParser.psm1'

#DscResourcesToExport = ''

# Version number of this module.
ModuleVersion = '0.2'

# ID used to uniquely identify this module
GUID = '136973e7-64da-494b-bf2d-38d4564bb8f5'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2016 Microsoft. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module with parser cmdlets to work with GP Registry Policy .pol files'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('GroupPolicy', 'DSC', 'DesiredStateConfiguration')

		# A URL to the license for this module.
		LicenseUri = 'https://github.com/PowerShell/GPRegistryPolicyParser/blob/master/LICENSE'

		# A URL to the main website for this project.
		ProjectUri = 'https://github.com/PowerShell/GPRegistryPolicyParser'

        # A URL to an icon representing this module.
        # IconUri = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

FunctionsToExport = @('Parse-PolFile','Read-RegistryPolicies','Create-RegistrySettingsEntry','Create-GPRegistryPolicyFile','Append-RegistryPolicies')
}
