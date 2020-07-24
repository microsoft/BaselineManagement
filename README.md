# BaselineManagement

[![Build Status](https://dev.azure.com/guestconfiguration/baselinemanagement_module/_apis/build/status/microsoft.BaselineManagement?branchName=master)](https://dev.azure.com/guestconfiguration/baselinemanagement_module/_build/latest?definitionId=36&branchName=master)

**NOTE:** Beginning with version 3.0.0, this module now only supports conversion from Group Policy format. If conversion from ASC or SCM formats is needed, please install version 2.x from the PowerShell Gallery.

This solution is built off [GPRegistryParser](https://github.com/PowerShell/GPRegistryPolicyParser).

This solution contains cmdlets for converting baselines into Desired State Configuration.

- ConvertFrom-GPO - Converts from GPO Backups into DSC Configuration and accompanying MOF.
- ConvertTo-DSC - "proxy" cmdlet that allows you to pass any of the baselines in and then automatically chooses the correct cmdlet for you.

All of the Cmdlets accept pipeline input and have accompanying help text and examples.

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

- GPRegistrPolicyParser
- SecurityPolicyDSC
- AuditPolicyDSC
- GPRegistrPolicyDSC

To install the latest stable version, use the following command.

```powershell
Install-Module BaselineManagement
```
