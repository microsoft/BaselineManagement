<#
.Synopsis
   DSC Configuration Template for DSC Resource Integration tests.
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename MSFT_<ResourceName>.config.ps1 (e.g. MSFT_xFirewall.config.ps1)
     2. Customize TODO sections.

.NOTES
#>

configuration 'MSFT_xAuditOption_config' {

    Import-DscResource -Name 'xAuditOption'

    node localhost {

        xAuditOption Integration_Test 
        {
            Name  = $optionName
            Value = $optionValue
        }
    }
}

# TODO: (Optional): Add More Configuration Templates
