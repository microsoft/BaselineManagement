DSCR_PowerPlan
====

PowerShell DSC Resource for Power Plan configuration

## Install
You can install Resource through [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_PowerPlan/).
```Powershell
Install-Module -Name DSCR_PowerPlan
```

## Resources
* **cPowerPlan**
PowerShell DSC Resource for create/change/remove Power Plan.

* **cPowerPlanSettings**
PowerShell DSC Resource for change Power settings & options.

## Properties

### cPowerPlan
+ [String] **Ensure** (Write):
    + Specifies existence state of Power Plan.
    + The default value is "Present". { Present | Absent }

+ [String] **Name** (Required):
    + The Name of Power Plan.

+ [String] **Description** (Write):
    + The Description of Power Plan.

+ [String] **GUID** (Key):
    + The GUID of Power Plan.
    + If you want to create Original Plan, should specify unique GUID.
    + If you want to set system default Plans, you can use aliases. {SCHEME_MAX | SCHEME_MIN | SCHEME_BALANCED}

+ [Boolean] **Active** (Write):
    + Specifies set or unset Power Plan as Active.
    + The default value is `$false`

### cPowerPlanSettings
+ [String] **SettingGuid** (Key):
    + The GUID of Power Setting.
    + You can obtain GUIDs by executing `powercfg.exe /Q` command
    + You can also use some aliases. The list of aliases is [here](https://github.com/mkht/DSCR_PowerPlan/blob/master/DSCResources/cPowerPlanSetting/DATA/GUID_LIST_SETTING).

+ [String] **PlanGuid** (Key):
    + The GUID of target Power Plan.
    + You can also use aliases. {ACTIVE | SCHEME_MAX | SCHEME_MIN | SCHEME_BALANCED}

+ [String] **AcDc** (Key):
    + You can choose {AC | DC | Both}
    + The default value is "Both"

+ [UInt32] **Value** (Required):
    + Specifies Power Setting value.


## Examples
### cPowerPlan
+ **Example 1**: Set "Balanced" Power Plan to Active
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_PowerPlan
    cPowerPlan Balanced_Active
    {
        Ensure = "Present"
        GUID   = "SCHEME_BALANCED"   # You can use alias
        Name   = "Balanced"
        Active  = $true
    }
}
```

+ **Example 2**: Create original Power Plan "PlanA"
```Powershell
Configuration Example2
{
    Import-DscResource -ModuleName DSCR_PowerPlan
    cPowerPlan PlanA
    {
        Ensure = "Present"
        GUID   = "ad98b5c7-06a1-493f-b611-da04c574e8b5"   # Unique GUID
        Name   = "PlanA"
        Description = "This is original Power Plan"
    }
}
```

### cPowerPlanSettings
+ **Example 1**: Set the duration of entering sleep to 5 minutes.
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_PowerPlan
    cPowerPlanSetting Sleep_5Min
    {
        PlanGuid    = 'ACTIVE'
        SettingGuid = 'STANDBYIDLE'
        Value       = 300   #sec
        AcDc        = 'Both'
    }
}
```

## ChangeLog
### 1.0.0
+ Add "Description" property for cPowerPLan
+ bug fix