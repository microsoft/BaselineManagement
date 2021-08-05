# Change Log for BaselineManagement module


## v4.1.1

- Fix issue where Registry INF settings did not return values
- 

## v4.1.0

- Adds Merge-GPOsFromOU command

## v4.0.1

- ConvertFrom-GPO minor fix to cleanup excess debug output

## v4.0.0

- BREAKING CHANGE
- Merge-GPOs: Refactored to only allow local execution
- Merge-GPOs: Fix error when processes local settings
- Merge-GPOs: Return object from ConvertFrom-GPO
- Merge-GPOs: Details about which policies were merged added to object returned rather than output to host
- ShowPesterOutput: Ignores parsing error regarding RequireLogonToChangePassword which is ignored by Windows
- ShowPesterOutput: Fix output count of parsing errors
- ShowPesterOutput: Fix outputpath was not called by ConvertFrom-GPO

## v3.1.4

- ConvertFrom-GPO: Fix configname string evaluation for space characters

## v3.1.3

- ConvertFrom-GPO: Fix bug where parameters are evaluated in "Begin" block using default value instead of pipeline input

## v3.1.2

- ConvertFrom-GPO: Fix "valuefrompipeline" not implemented for ConfigName (by alias, to support piping from backup-gpo)

## v3.1.1

- Minor fix across modules so messages are written to verbose stream rather than warning stream, unless they are warnings
- Add parameter aliases to align with BackUp-GPO cmdlet
- Fix bug in ConvertFrom-GPO where "return" included output from "mkdir" command if output path did not already exist

## v3.1.0

- ConvertFrom-GPO: Update to return object with properties organizing information about what has been output
- ConvertFrom-GPO: Add 'PassThru' parameter to to retain previous outputbehavior if desired
## v3.0.0

- refactored to remove support for formats other than Group Policy
  - removed parsers
  - removed tests
- Add support for Group Policy Client Side Extension
  - switched from Registry resource in PSDscResources module to RegistryPolicyFile resource in GPRegistryPolicyDsc module
  - added RefreshRegistryPolicy to end of configuration block (in all cases)
- remove external modules available in gallery
- minor changes to comments where appropriate (typo's, etc)
- started change log