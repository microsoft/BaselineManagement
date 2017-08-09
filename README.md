This solution is built off GPRegistryParser found here: https://github.com/PowerShell/GPRegistryPolicyParser

Upon Importing the Module BaselineManagement
	Import-Module BaselineManagement 

There will be one 3 main cmdlets:

These cmdlets are designed to convert from baselines in Group Policy or SCM into corresponding DSC Configurations and MOF Files.
 - ConvertFrom-GPO - Converts from GPO Backups into DSC Configuration and accompanying MOF
 - ConvertFrom-SCM - Converts from SCMXML into DSC Configuration and accompanying MOF
 - ConvertFrom-ASC - Converts from SCMJSON into DSC Configuration and accompanying MOF

 - ConvertTo-DSC - "proxy" cmdlet that allows you to pass any of the baselines in and then automatically chooses the correct cmdlet for you.

All of the Cmdlets accept pipeline input and have accompanying help text and examples.

Upon passing an appropriate baseline into the proper cmdlet, the tool will automatically convert it into a DSC Configuration and attempt to compile it against localhost.
There is also a parameter to output the configuration PS1 file if needed. 
If there are any errors compiling or creating the configuration, the tool will output a ps1.error file with the configuration text.

The accompanying resources stored in the DSC resources folder are needed to apply the settings.  Most can be found on github, but are stored here for convenience.

PLEASE NOTE: If the resources are not copied into a PSModulePath the Configuration will likely not compile.  
This is simply because DSC requires that all modules in a Configuration be present in PSModulePath when compiled.

The tool has a conflict resolution engine that will automatically comment out conflicting resources.
Ex.

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

The same engine will also comment out resources that are marked as DISABLED in SCM baselines.

If comments are available they will be parsed and added above corresponding resources.
 - SCMXML - Comments will be parsed
 - SCMJSON - Comments will NOT be parsed
 - GPO - Comments will NOT be parsed
 
This tool was designed for two main purposes.
 - Allow conversion of GPOS into DSC for application or auditing.
 - Allow remediation of SCM baselines.

The tool has been thoroughly tested, but needs to be run against a variety of baselines to ensure they are parsed correctly.

TO ASSIST with parsing new baselines:
 - I designed the Pester tests to work off sample baselines stored in the TESTS folder.  
You can replace these with any baselines you want to test conversion of to seee more verbose output.

Additional SCM Baselines are currently in the work
 - Currently Complete: OS

If you have any issues, please submit them and I will get to them as I am able :-)



