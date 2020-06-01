# BaselineManagement

This solution is built off [GPRegistryParser](https://github.com/PowerShell/GPRegistryPolicyParser).

This solution contains cmdlets for converting baselines into Desired State Configuration.

- ConvertFrom-GPO - Converts from GPO Backups into DSC Configuration and accompanying MOF.
- ConvertFrom-SCM - Converts from SCM `.xml` files into DSC Configuration and accompanying MOF.
- ConvertFrom-ASC - Converts from Azure Security Center `.json` files into DSC Configuration and accompanying MOF.

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

The same engine will also comment out resources that are marked as DISABLED in SCM baselines.

If comments are available they will be parsed and added above corresponding resources.

- SCM `.xml` - Comments will be parsed
- ASC `.json` - Comments will NOT be parsed
- GPO - Comments will NOT be parsed

This tool was designed for two main purposes.

- Allow conversion of GPOS into DSC for application or auditing.
- Allow remediation of SCM/ASC baselines.

The tool has been thoroughly tested, but needs to be run against a variety of baselines to ensure they are parsed correctly.

If you have any issues, please submit them and I will get to them as I am able :-)

## Install the Module

**BaselineManagement** is also available on the PowerShell gallery, where dependent modules are
automatically installed:

- SecurityPolicyDSC
- AuditPolicyDSC
- GPRegistrPolicyParser
- PSDscResoureces

To install the latest stable version, use the following command.

```powershell
Install-Module BaselineManagement
```
