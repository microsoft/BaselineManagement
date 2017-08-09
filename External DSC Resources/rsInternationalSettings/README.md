rsInternationalSettings DSC Module
=======================

**rsInternationalSettings** is a PowerShell DSC resource module, which can be used to manage international system settings such as setting system locale, time zone user keyboard layout and culture (formatting) settings.

##Changelog

######2.2.0
Added support for setting manual peer list for NTP servers in rsTime using the PeerList variable
######2.1.0
Added support for setting time zone, culture, system local and all local (including default) user profile settings.

##Syntax##

See usage examples below...

###Usage Examples

**Set Server to US locale and user input**

This will force all system and user settings to US codepage, including input setting:

    rsSysLocale SysLoc
    {
    	SysLocale = "en-US"
    }
    
    rsTime time
    {
    	TimeZone = "Central Standard Time"
    }
    
    rsUserLocale UserLocale
    {
    	Name = "UserLocale"
		Culture = "en-US"
    	LocationID = "244"
    	LCIDHex = "0409"
    	InputLocaleID = "00000409"
    }


**Set Server to UK locale and user input**

This will force all system and user settings to UK codepage, including input setting:

    rsSysLocale SysLoc
    {
    	SysLocale = "en-GB"
    }
    
    rsTime time
    {
    	TimeZone = "GMT Standard Time"
    }
    
    rsUserLocale UserLocale
    {
    	Name = "UserLocale"
		Culture = "en-GB"
    	LocationID = "242"
    	LCIDHex = "0809"
    	InputLocaleID = "00000809"
    }

**Add manual NTP peer server list**

To override the default time.windows.com NTP server or the automatic AD member time synchronisation, you can specify the PeerList parameter for rsTime, which will register the Windows Time service and configure it accordingly. Please note that omitting this parameter will always result in Windows Time Service to be unregistered if one is running already.

    rsTime time
    {
        TimeZone = "GMT Standard Time"
        PeerList = @("0.pool.ntp.org","1.pool.ntp.org","2.pool.ntp.org")
    }

###Acceptable parameter values

#####$Culture
Default system codepage for non-Unicode applications. 
Use the following PowerShell command to list all available options:

    [cultureinfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures)

#####$TimeZone
System time zone name description. Ex "GMT Standard Time"
Use the `tzutil /l` command to list all possible options.

#####$PeerList
An array of NTP servers to configure the local Windows Time service.

#####$LocationID
Geographical System location ID (GEOID). Refer to [Table of Geographical Locations](http://msdn.microsoft.com/en-us/library/windows/desktop/dd374073(v=vs.85).aspx) for full list of possible options.

#####$LCIDHex
Keyboard Language ID as defined by Microsoft. Used in combination with InputLocaleID, see [Keyboard Language & Locale IDs Assigned by Microsoft](http://msdn.microsoft.com/en-gb/goglobal/bb895996.aspx)

#####$InputLocaleID
Locale ID as defined by Microsoft. Used in combination with LCIDHex, see [Keyboard Language & Locale IDs Assigned by Microsoft](http://msdn.microsoft.com/en-gb/goglobal/bb895996.aspx)

###Keyboard options tip:
To easily identify correct settings for user keyboard options (*LCIDHex* & *InputLocaleID*), set the desired keyboard settings on a Windows 8/2012, or later, machine and run the following PS command `Get-WinUserLanguageList`. Property named "InputMethodTips" will provide the correct Language Code ID as `{<LCIDHex>:<InputLocaleID>}`.

#####Example:

    PS C:\Users\Administrator> Get-WinUserLanguageList
    
    LanguageTag : en-US
    Autonym : English (United States)
    EnglishName : English
    LocalizedName   : English (United States)
    ScriptName  : Latin script
    InputMethodTips : {0409:00000409}
    Spellchecking   : True
    Handwriting : False

