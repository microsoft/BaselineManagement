# BaselineManagement

Master:
[![Build Status](https://dev.azure.com/guestconfiguration/baselinemanagement_module/_apis/build/status/microsoft.BaselineManagement?branchName=master)](https://dev.azure.com/guestconfiguration/baselinemanagement_module/_build/latest?definitionId=48&branchName=master)

**NOTE:** Beginning with version 3.0.0, this module now only supports conversion from Group Policy format. If conversion from ASC or SCM formats is needed, please install version 2.x from the PowerShell Gallery.

This solution is built off [GPRegistryParser](https://github.com/PowerShell/GPRegistryPolicyParser).

This solution contains cmdlets for converting baselines into Desired State Configuration.

- ConvertFrom-GPO - Converts from GPO Backups into DSC Configuration and accompanying MOF.
- Merge-GPOs - Discovers the result of all policies for a machine by querying WMI from inside the machine. and creates a single DSC script based on the order policies are applied, link, enforcement, and filtering.
- Merge-GPOsFromOU - Discovers the result of all policies assigned at the scope of an OU, and creates a single DSC script based on the order policies are applied, link, and enforcement.

All of the Cmdlets accept pipeline input and have accompanying help text and examples.

## Known gaps in capability

- **Security settings that are producing errors**
  - Network_security_Configure_encryption_types_allowed_for_Kerberos: if multiple values are selected, the value will not resolve to a name and will produce an error. This will have to be resolved in SecurityPolicyDSC.
  <br>[Issue tracked in SecurityPolicyDsc](https://github.com/dsccommunity/SecurityPolicyDsc/issues/167)
  - Network_access_Restrict_clients_allowed_to_make_remote_calls_to_SAM: the format of the value for this setting is causing the MOF to not compile correctly. The only workaround for now is to not include the setting or manually set it in the MOF (if the correct value is known).
  - Minimum_password_length_audit: this is a new setting that hasn't been mapped yet in SecurityPolicyDsc.
  <br>[Issue tracked in SecurityPolicyDsc](https://github.com/dsccommunity/SecurityPolicyDsc/issues/166)

- **Not all Group Policy settings have DSC resources, or parsers**
  - Some are tracked in the Issues list but it is likely there are many edge cases not yet covered.
## Description

The included cmdlets convert baselines into a Desired State Configuration `.mof` file and, optionally, a `.ps1` file.
If there are any errors compiling or creating the configuration, the tool will output a `ps1.error` file with the configuration text.

The accompanying resources stored in the DSC resources folder are needed to apply the settings. Most can be found on github, but are stored here for convenience.

> [!NOTE]
> If the resources are not copied into a PSModulePath the Configuration will likely not compile.
> This is simply because DSC requires that all modules in a Configuration be present in PSModulePath when compiled.

The tool also has a conflict resolution engine that will automatically comment out conflicting resources.

### Example of Conflict Resolution

```powershell
    Service Spooler
    {
        Name = "Spooler"
        State = "Stopped"
    }

    Service Spooler2
    {
        Name = "Spooler"
        State = "Running"
    }
```

The tool has been thoroughly tested, but needs to be run against a variety of baselines to ensure they are parsed correctly.

If you have any issues, please submit them and I will get to them as I am able :-)

## Install the Module

**BaselineManagement** is also available on the PowerShell gallery, where dependent modules are
automatically installed:

- GPRegistryPolicyParser
- SecurityPolicyDSC
- AuditPolicyDSC
- GPRegistryPolicyDSC

To install the latest stable version, use the following command.

```powershell
Install-Module BaselineManagement
```
