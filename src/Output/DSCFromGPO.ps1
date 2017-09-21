       
Configuration DSCFromGPO
{

	Import-DSCResource -ModuleName 'PSDesiredStateConfiguration'
	Import-DSCResource -ModuleName 'AuditPolicyDSC'
	Import-DSCResource -ModuleName 'SecurityPolicyDSC'
	Import-DSCResource -ModuleName 'BaselineManagement'
	Import-DSCResource -ModuleName 'xSMBShare'
	Import-DSCResource -ModuleName 'DSCR_PowerPlan'
	Import-DSCResource -ModuleName 'xScheduledTask'
	Import-DSCResource -ModuleName 'Carbon'
	Import-DSCResource -ModuleName 'PrinterManagement'
	Import-DSCResource -ModuleName 'rsInternationalSettings'
	Node localhost
	{
	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\CredUI\EnumerateAdministrators'
	 	{
	 	 	ValueName = 'EnumerateAdministrators'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\CredUI'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoInternetOpenWith'
	 	{
	 	 	ValueName = 'NoInternetOpenWith'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoAutorun'
	 	{
	 	 	ValueName = 'NoAutorun'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun'
	 	{
	 	 	ValueName = 'NoDriveTypeAutoRun'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\PreXPSP2ShellProtocolBehavior'
	 	{
	 	 	ValueName = 'PreXPSP2ShellProtocolBehavior'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDisconnect'
	 	{
	 	 	ValueName = 'NoDisconnect'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing\LocalSourcePath'
	 	{
	 	 	ValueName = 'LocalSourcePath'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing\UseWindowsUpdate'
	 	{
	 	 	ValueName = 'UseWindowsUpdate'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing'

	 	}

	 	Registry 'DEL_\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing\RepairContentServerSource'
	 	{
	 	 	ValueName = 'RepairContentServerSource'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'DEL_\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableBkGndGroupPolicy'
	 	{
	 	 	ValueName = 'DisableBkGndGroupPolicy'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ReportControllerMissing'
	 	{
	 	 	ValueName = 'ReportControllerMissing'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\MSAOptional'
	 	{
	 	 	ValueName = 'MSAOptional'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableAutomaticRestartSignOn'
	 	{
	 	 	ValueName = 'DisableAutomaticRestartSignOn'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit\ProcessCreationIncludeCmdLine_Enabled'
	 	{
	 	 	ValueName = 'ProcessCreationIncludeCmdLine_Enabled'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Biometrics\Enabled'
	 	{
	 	 	ValueName = 'Enabled'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Biometrics'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Control Panel\International\BlockUserInputMethodsForSignIn'
	 	{
	 	 	ValueName = 'BlockUserInputMethodsForSignIn'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Control Panel\International'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\IE'
	 	{
	 	 	ValueName = 'IE'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Wordpad'
	 	{
	 	 	ValueName = 'Wordpad'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Outlook'
	 	{
	 	 	ValueName = 'Outlook'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Word'
	 	{
	 	 	ValueName = 'Word'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Excel'
	 	{
	 	 	ValueName = 'Excel'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\PowerPoint'
	 	{
	 	 	ValueName = 'PowerPoint'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Access'
	 	{
	 	 	ValueName = 'Access'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Publisher'
	 	{
	 	 	ValueName = 'Publisher'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\InfoPath'
	 	{
	 	 	ValueName = 'InfoPath'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Visio'
	 	{
	 	 	ValueName = 'Visio'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\VisioViewer'
	 	{
	 	 	ValueName = 'VisioViewer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Lync'
	 	{
	 	 	ValueName = 'Lync'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\PPTViewer'
	 	{
	 	 	ValueName = 'PPTViewer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Picture Manager'
	 	{
	 	 	ValueName = 'Picture Manager'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\AcrobatReader'
	 	{
	 	 	ValueName = 'AcrobatReader'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Acrobat'
	 	{
	 	 	ValueName = 'Acrobat'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre6_java'
	 	{
	 	 	ValueName = 'jre6_java'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre6_javaw'
	 	{
	 	 	ValueName = 'jre6_javaw'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre6_javaws'
	 	{
	 	 	ValueName = 'jre6_javaws'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre7_java'
	 	{
	 	 	ValueName = 'jre7_java'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre7_javaw'
	 	{
	 	 	ValueName = 'jre7_javaw'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre7_javaws'
	 	{
	 	 	ValueName = 'jre7_javaws'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre8_java'
	 	{
	 	 	ValueName = 'jre8_java'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre8_javaw'
	 	{
	 	 	ValueName = 'jre8_javaw'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\jre8_javaws'
	 	{
	 	 	ValueName = 'jre8_javaws'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\WindowsMediaPlayer'
	 	{
	 	 	ValueName = 'WindowsMediaPlayer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Skype'
	 	{
	 	 	ValueName = 'Skype'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\LyncCommunicator'
	 	{
	 	 	ValueName = 'LyncCommunicator'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\WindowsLiveMail'
	 	{
	 	 	ValueName = 'WindowsLiveMail'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\PhotoGallery'
	 	{
	 	 	ValueName = 'PhotoGallery'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\LiveWriter'
	 	{
	 	 	ValueName = 'LiveWriter'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\SkyDrive'
	 	{
	 	 	ValueName = 'SkyDrive'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Chrome'
	 	{
	 	 	ValueName = 'Chrome'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\GoogleTalk'
	 	{
	 	 	ValueName = 'GoogleTalk'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Firefox'
	 	{
	 	 	ValueName = 'Firefox'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\FirefoxPluginContainer'
	 	{
	 	 	ValueName = 'FirefoxPluginContainer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Thunderbird'
	 	{
	 	 	ValueName = 'Thunderbird'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\ThunderbirdPluginContainer'
	 	{
	 	 	ValueName = 'ThunderbirdPluginContainer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Photoshop'
	 	{
	 	 	ValueName = 'Photoshop'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Winamp'
	 	{
	 	 	ValueName = 'Winamp'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Opera'
	 	{
	 	 	ValueName = 'Opera'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Opera_New_Versions'
	 	{
	 	 	ValueName = 'Opera_New_Versions'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\WinRARGUI'
	 	{
	 	 	ValueName = 'WinRARGUI'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\WinRARConsole'
	 	{
	 	 	ValueName = 'WinRARConsole'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\UnRAR'
	 	{
	 	 	ValueName = 'UnRAR'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Winzip'
	 	{
	 	 	ValueName = 'Winzip'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Winzip64'
	 	{
	 	 	ValueName = 'Winzip64'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\VLC'
	 	{
	 	 	ValueName = 'VLC'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\RealConverter'
	 	{
	 	 	ValueName = 'RealConverter'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\RealPlayer'
	 	{
	 	 	ValueName = 'RealPlayer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\mIRC'
	 	{
	 	 	ValueName = 'mIRC'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\7z'
	 	{
	 	 	ValueName = '7z'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\7zGUI'
	 	{
	 	 	ValueName = '7zGUI'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\7zFM'
	 	{
	 	 	ValueName = '7zFM'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Safari'
	 	{
	 	 	ValueName = 'Safari'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\QuickTimePlayer'
	 	{
	 	 	ValueName = 'QuickTimePlayer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\iTunes'
	 	{
	 	 	ValueName = 'iTunes'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\Pidgin'
	 	{
	 	 	ValueName = 'Pidgin'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\Defaults\FoxitReader'
	 	{
	 	 	ValueName = 'FoxitReader'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\Defaults'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\SysSettings\ASLR'
	 	{
	 	 	ValueName = 'ASLR'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\SysSettings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\SysSettings\DEP'
	 	{
	 	 	ValueName = 'DEP'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\SysSettings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EMET\SysSettings\SEHOP'
	 	{
	 	 	ValueName = 'SEHOP'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EMET\SysSettings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\EventViewer\MicrosoftEventVwrDisableLinks'
	 	{
	 	 	ValueName = 'MicrosoftEventVwrDisableLinks'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\EventViewer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Feeds\DisableEnclosureDownload'
	 	{
	 	 	ValueName = 'DisableEnclosureDownload'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Feeds'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Feeds\AllowBasicAuthInClear'
	 	{
	 	 	ValueName = 'AllowBasicAuthInClear'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Feeds'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Peernet\Disabled'
	 	{
	 	 	ValueName = 'Disabled'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Peernet'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51\DCSettingIndex'
	 	{
	 	 	ValueName = 'DCSettingIndex'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51\ACSettingIndex'
	 	{
	 	 	ValueName = 'ACSettingIndex'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E\DCSettingIndex'
	 	{
	 	 	ValueName = 'DCSettingIndex'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E\ACSettingIndex'
	 	{
	 	 	ValueName = 'ACSettingIndex'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\SQMClient\Windows\CEIPEnable'
	 	{
	 	 	ValueName = 'CEIPEnable'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\SQMClient\Windows'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot\DisableRootAutoUpdate'
	 	{
	 	 	ValueName = 'DisableRootAutoUpdate'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\AppCompat\DisablePcaUI'
	 	{
	 	 	ValueName = 'DisablePcaUI'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\AppCompat'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\AppCompat\DisableInventory'
	 	{
	 	 	ValueName = 'DisableInventory'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\AppCompat'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Appx\AllowAllTrustedApps'
	 	{
	 	 	ValueName = 'AllowAllTrustedApps'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Appx'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CredUI\DisablePasswordReveal'
	 	{
	 	 	ValueName = 'DisablePasswordReveal'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\CredUI'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Device Metadata\PreventDeviceMetadataFromNetwork'
	 	{
	 	 	ValueName = 'PreventDeviceMetadataFromNetwork'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Device Metadata'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings\AllowRemoteRPC'
	 	{
	 	 	ValueName = 'AllowRemoteRPC'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings\DisableSendGenericDriverNotFoundToWER'
	 	{
	 	 	ValueName = 'DisableSendGenericDriverNotFoundToWER'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings\DisableSystemRestore'
	 	{
	 	 	ValueName = 'DisableSystemRestore'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings\DisableSendRequestAdditionalSoftwareToWER'
	 	{
	 	 	ValueName = 'DisableSendRequestAdditionalSoftwareToWER'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DriverSearching\SearchOrderConfig'
	 	{
	 	 	ValueName = 'SearchOrderConfig'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DriverSearching'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DriverSearching\DriverServerSelection'
	 	{
	 	 	ValueName = 'DriverServerSelection'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DriverSearching'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DriverSearching\DontPromptForWindowsUpdate'
	 	{
	 	 	ValueName = 'DontPromptForWindowsUpdate'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DriverSearching'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\DriverSearching\DontSearchWindowsUpdate'
	 	{
	 	 	ValueName = 'DontSearchWindowsUpdate'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\DriverSearching'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\Application\MaxSize'
	 	{
	 	 	ValueName = 'MaxSize'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Application'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\Security\MaxSize'
	 	{
	 	 	ValueName = 'MaxSize'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Security'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\Setup\MaxSize'
	 	{
	 	 	ValueName = 'MaxSize'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Setup'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\System\MaxSize'
	 	{
	 	 	ValueName = 'MaxSize'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith'
	 	{
	 	 	ValueName = 'NoUseStoreOpenWith'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Explorer\NoAutoplayfornonVolume'
	 	{
	 	 	ValueName = 'NoAutoplayfornonVolume'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Explorer\NoDataExecutionPrevention'
	 	{
	 	 	ValueName = 'NoDataExecutionPrevention'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Explorer\NoHeapTerminationOnCorruption'
	 	{
	 	 	ValueName = 'NoHeapTerminationOnCorruption'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}\NoBackgroundPolicy'
	 	{
	 	 	ValueName = 'NoBackgroundPolicy'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}\NoGPOListChanges'
	 	{
	 	 	ValueName = 'NoGPOListChanges'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\PreventHandwritingErrorReports'
	 	{
	 	 	ValueName = 'PreventHandwritingErrorReports'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Installer\EnableUserControl'
	 	{
	 	 	ValueName = 'EnableUserControl'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Installer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated'
	 	{
	 	 	ValueName = 'AlwaysInstallElevated'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Installer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Installer\SafeForScripting'
	 	{
	 	 	ValueName = 'SafeForScripting'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Installer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Installer\DisableLUAPatching'
	 	{
	 	 	ValueName = 'DisableLUAPatching'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Installer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\EnableLLTDIO'
	 	{
	 	 	ValueName = 'EnableLLTDIO'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\AllowLLTDIOOnDomain'
	 	{
	 	 	ValueName = 'AllowLLTDIOOnDomain'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\AllowLLTDIOOnPublicNet'
	 	{
	 	 	ValueName = 'AllowLLTDIOOnPublicNet'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\ProhibitLLTDIOOnPrivateNet'
	 	{
	 	 	ValueName = 'ProhibitLLTDIOOnPrivateNet'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\EnableRspndr'
	 	{
	 	 	ValueName = 'EnableRspndr'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\AllowRspndrOnDomain'
	 	{
	 	 	ValueName = 'AllowRspndrOnDomain'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\AllowRspndrOnPublicNet'
	 	{
	 	 	ValueName = 'AllowRspndrOnPublicNet'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LLTD\ProhibitRspndrOnPrivateNet'
	 	{
	 	 	ValueName = 'ProhibitRspndrOnPrivateNet'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LLTD'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors\DisableLocation'
	 	{
	 	 	ValueName = 'DisableLocation'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Network Connections\NC_AllowNetBridge_NLA'
	 	{
	 	 	ValueName = 'NC_AllowNetBridge_NLA'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Network Connections'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Network Connections\NC_StdDomainUserSetLocation'
	 	{
	 	 	ValueName = 'NC_StdDomainUserSetLocation'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Network Connections'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Personalization\NoLockScreenSlideshow'
	 	{
	 	 	ValueName = 'NoLockScreenSlideshow'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Personalization'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy\DisableQueryRemoteServer'
	 	{
	 	 	ValueName = 'DisableQueryRemoteServer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy\EnableQueryRemoteServer'
	 	{
	 	 	ValueName = 'EnableQueryRemoteServer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Appx\'
	 	{
	 	 	ValueName = ''
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Appx'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Dll\'
	 	{
	 	 	ValueName = ''
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Dll'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\921cc481-6e17-4653-8f75-050b80acca20\Value'
	 	{
	 	 	ValueName = 'Value'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\921cc481-6e17-4653-8f75-050b80acca20'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\a61c8b2c-a319-4cd0-9690-d2177cad7b51\Value'
	 	{
	 	 	ValueName = 'Value'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\a61c8b2c-a319-4cd0-9690-d2177cad7b51'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\fd686d83-a829-4351-8ff4-27c7de5755d2\Value'
	 	{
	 	 	ValueName = 'Value'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\fd686d83-a829-4351-8ff4-27c7de5755d2'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Msi\'
	 	{
	 	 	ValueName = ''
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Msi'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Script\'
	 	{
	 	 	ValueName = ''
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Script'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\EnumerateLocalUsers'
	 	{
	 	 	ValueName = 'EnumerateLocalUsers'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\DisableLockScreenAppNotifications'
	 	{
	 	 	ValueName = 'DisableLockScreenAppNotifications'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\EnableSmartScreen'
	 	{
	 	 	ValueName = 'EnableSmartScreen'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\DontDisplayNetworkSelectionUI'
	 	{
	 	 	ValueName = 'DontDisplayNetworkSelectionUI'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\Force_Tunneling'
	 	{
	 	 	ValueName = 'Force_Tunneling'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\6to4_State'
	 	{
	 	 	ValueName = '6to4_State'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\ISATAP_State'
	 	{
	 	 	ValueName = 'ISATAP_State'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\Teredo_State'
	 	{
	 	 	ValueName = 'Teredo_State'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\IPHTTPS\IPHTTPSInterface\IPHTTPS_ClientUrl'
	 	{
	 	 	ValueName = 'IPHTTPS_ClientUrl'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\IPHTTPS\IPHTTPSInterface'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\IPHTTPS\IPHTTPSInterface\IPHTTPS_ClientState'
	 	{
	 	 	ValueName = 'IPHTTPS_ClientState'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\IPHTTPS\IPHTTPSInterface'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars\EnableRegistrars'
	 	{
	 	 	ValueName = 'EnableRegistrars'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars\DisableUPnPRegistrar'
	 	{
	 	 	ValueName = 'DisableUPnPRegistrar'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars\DisableInBand802DOT11Registrar'
	 	{
	 	 	ValueName = 'DisableInBand802DOT11Registrar'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars\DisableFlashConfigRegistrar'
	 	{
	 	 	ValueName = 'DisableFlashConfigRegistrar'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars\DisableWPDRegistrar'
	 	{
	 	 	ValueName = 'DisableWPDRegistrar'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows\WCN\Registrars\MaxWCNDeviceNumber'
	 	{
	 	 	ValueName = 'MaxWCNDeviceNumber'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows\WCN\Registrars\HigherPrecedenceRegistrar'
	 	{
	 	 	ValueName = 'HigherPrecedenceRegistrar'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\Registrars'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WCN\UI\DisableWcnUi'
	 	{
	 	 	ValueName = 'DisableWcnUi'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WCN\UI'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}\ScenarioExecutionEnabled'
	 	{
	 	 	ValueName = 'ScenarioExecutionEnabled'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\Disabled'
	 	{
	 	 	ValueName = 'Disabled'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\LoggingDisabled'
	 	{
	 	 	ValueName = 'LoggingDisabled'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\DontSendAdditionalData'
	 	{
	 	 	ValueName = 'DontSendAdditionalData'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\BypassDataThrottling'
	 	{
	 	 	ValueName = 'BypassDataThrottling'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\DontShowUI'
	 	{
	 	 	ValueName = 'DontShowUI'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\CorporateWerServer'
	 	{
	 	 	ValueName = 'CorporateWerServer'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\CorporateWerUseSSL'
	 	{
	 	 	ValueName = 'CorporateWerUseSSL'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\CorporateWerPortNumber'
	 	{
	 	 	ValueName = 'CorporateWerPortNumber'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\DisableArchive'
	 	{
	 	 	ValueName = 'DisableArchive'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\ConfigureArchive'
	 	{
	 	 	ValueName = 'ConfigureArchive'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\MaxArchiveCount'
	 	{
	 	 	ValueName = 'MaxArchiveCount'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\DisableQueue'
	 	{
	 	 	ValueName = 'DisableQueue'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\ForceQueue'
	 	{
	 	 	ValueName = 'ForceQueue'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\MaxQueueCount'
	 	{
	 	 	ValueName = 'MaxQueueCount'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\MaxQueueSize'
	 	{
	 	 	ValueName = 'MaxQueueSize'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\MinFreeDiskSpace'
	 	{
	 	 	ValueName = 'MinFreeDiskSpace'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\QueuePesterInterval'
	 	{
	 	 	ValueName = 'QueuePesterInterval'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\Consent\DefaultConsent'
	 	{
	 	 	ValueName = 'DefaultConsent'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\Consent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\Consent\DefaultOverrideBehavior'
	 	{
	 	 	ValueName = 'DefaultOverrideBehavior'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting\Consent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client\AllowBasic'
	 	{
	 	 	ValueName = 'AllowBasic'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client\AllowUnencryptedTraffic'
	 	{
	 	 	ValueName = 'AllowUnencryptedTraffic'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client\AllowDigest'
	 	{
	 	 	ValueName = 'AllowDigest'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\AllowBasic'
	 	{
	 	 	ValueName = 'AllowBasic'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\AllowUnencryptedTraffic'
	 	{
	 	 	ValueName = 'AllowUnencryptedTraffic'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\DisableRunAs'
	 	{
	 	 	ValueName = 'DisableRunAs'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows Defender\Spynet\SpynetReporting'
	 	{
	 	 	ValueName = 'SpynetReporting'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Printers\DoNotInstallCompatibleDriverFromWindowsUpdate'
	 	{
	 	 	ValueName = 'DoNotInstallCompatibleDriverFromWindowsUpdate'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Printers'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Printers\DisableWebPnPDownload'
	 	{
	 	 	ValueName = 'DisableWebPnPDownload'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Printers'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Printers\DisableHTTPPrinting'
	 	{
	 	 	ValueName = 'DisableHTTPPrinting'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Printers'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Rpc\EnableAuthEpResolution'
	 	{
	 	 	ValueName = 'EnableAuthEpResolution'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Rpc'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fAllowUnsolicited'
	 	{
	 	 	ValueName = 'fAllowUnsolicited'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\fAllowUnsolicitedFullControl'
	 	{
	 	 	ValueName = 'fAllowUnsolicitedFullControl'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fAllowToGetHelp'
	 	{
	 	 	ValueName = 'fAllowToGetHelp'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\fAllowFullControl'
	 	{
	 	 	ValueName = 'fAllowFullControl'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\MaxTicketExpiry'
	 	{
	 	 	ValueName = 'MaxTicketExpiry'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\MaxTicketExpiryUnits'
	 	{
	 	 	ValueName = 'MaxTicketExpiryUnits'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\fUseMailto'
	 	{
	 	 	ValueName = 'fUseMailto'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
	 	 	Ensure = 'Absent'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\LoggingEnabled'
	 	{
	 	 	ValueName = 'LoggingEnabled'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\DisablePasswordSaving'
	 	{
	 	 	ValueName = 'DisablePasswordSaving'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fDisableCdm'
	 	{
	 	 	ValueName = 'fDisableCdm'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fPromptForPassword'
	 	{
	 	 	ValueName = 'fPromptForPassword'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\MinEncryptionLevel'
	 	{
	 	 	ValueName = 'MinEncryptionLevel'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\MaxIdleTime'
	 	{
	 	 	ValueName = 'MaxIdleTime'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\MaxDisconnectionTime'
	 	{
	 	 	ValueName = 'MaxDisconnectionTime'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\DeleteTempDirsOnExit'
	 	{
	 	 	ValueName = 'DeleteTempDirsOnExit'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\PerSessionTempDir'
	 	{
	 	 	ValueName = 'PerSessionTempDir'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fEncryptRPCTraffic'
	 	{
	 	 	ValueName = 'fEncryptRPCTraffic'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fSingleSessionPerUser'
	 	{
	 	 	ValueName = 'fSingleSessionPerUser'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fDisableCcm'
	 	{
	 	 	ValueName = 'fDisableCcm'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fDisableLPT'
	 	{
	 	 	ValueName = 'fDisableLPT'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fEnableSmartCard'
	 	{
	 	 	ValueName = 'fEnableSmartCard'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fDisablePNPRedir'
	 	{
	 	 	ValueName = 'fDisablePNPRedir'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\RedirectOnlyDefaultClientPrinter'
	 	{
	 	 	ValueName = 'RedirectOnlyDefaultClientPrinter'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'

	 	}

	 	<#Registry 'DELVALS_\Software\Policies\Microsoft\Windows NT\Terminal Services\RAUnsolicit'
	 	{
	 	 	ValueName = ''
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\RAUnsolicit'
	 	 	Ensure = 'Present'
	 	 	Exclusive = $True

	 	}#>

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer\GroupPrivacyAcceptance'
	 	{
	 	 	ValueName = 'GroupPrivacyAcceptance'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer\DisableAutoUpdate'
	 	{
	 	 	ValueName = 'DisableAutoUpdate'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsStore\AutoDownload'
	 	{
	 	 	ValueName = 'AutoDownload'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\WindowsStore'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsStore\RemoveWindowsStore'
	 	{
	 	 	ValueName = 'RemoveWindowsStore'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\WindowsStore'

	 	}

	 	Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WMDRM\DisableOnline'
	 	{
	 	 	ValueName = 'DisableOnline'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\WMDRM'

	 	}

	 	Registry 'Registry(POL): HKLM:\System\CurrentControlSet\Policies\EarlyLaunch\DriverLoadPolicy'
	 	{
	 	 	ValueName = 'DriverLoadPolicy'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Policies\EarlyLaunch'

	 	}

	 	Registry 'Registry(POL): HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\EnableIPAutoConfigurationLimits'
	 	{
	 	 	ValueName = 'EnableIPAutoConfigurationLimits'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters'

	 	}

	 	AuditPolicySubcategory 'Audit Credential Validation (Success) - Inclusion'
	 	{
	 	 	Name = 'Credential Validation'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Credential Validation (Failure) - Inclusion'
	 	{
	 	 	Name = 'Credential Validation'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Computer Account Management (Success) - Inclusion'
	 	{
	 	 	Name = 'Computer Account Management'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Computer Account Management (Failure) - Inclusion'
	 	{
	 	 	Name = 'Computer Account Management'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Other Account Management Events (Success) - Inclusion'
	 	{
	 	 	Name = 'Other Account Management Events'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Other Account Management Events (Failure) - Inclusion'
	 	{
	 	 	Name = 'Other Account Management Events'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Security Group Management (Success) - Inclusion'
	 	{
	 	 	Name = 'Security Group Management'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Security Group Management (Failure) - Inclusion'
	 	{
	 	 	Name = 'Security Group Management'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit User Account Management (Success) - Inclusion'
	 	{
	 	 	Name = 'User Account Management'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit User Account Management (Failure) - Inclusion'
	 	{
	 	 	Name = 'User Account Management'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Process Creation - Inclusion'
	 	{
	 	 	Name = 'Process Creation'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

	 	AuditPolicySubcategory 'Audit Directory Service Access (Success) - Inclusion'
	 	{
	 	 	Name = 'Directory Service Access'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Directory Service Access (Failure) - Inclusion'
	 	{
	 	 	Name = 'Directory Service Access'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Directory Service Changes (Success) - Inclusion'
	 	{
	 	 	Name = 'Directory Service Changes'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Directory Service Changes (Failure) - Inclusion'
	 	{
	 	 	Name = 'Directory Service Changes'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Logoff - Inclusion'
	 	{
	 	 	Name = 'Logoff'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

	 	AuditPolicySubcategory 'Audit Logon (Success) - Inclusion'
	 	{
	 	 	Name = 'Logon'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Logon (Failure) - Inclusion'
	 	{
	 	 	Name = 'Logon'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Special Logon - Inclusion'
	 	{
	 	 	Name = 'Special Logon'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

	 	AuditPolicySubcategory 'Audit File System - Inclusion'
	 	{
	 	 	Name = 'File System'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Handle Manipulation - Inclusion'
	 	{
	 	 	Name = 'Handle Manipulation'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Registry - Inclusion'
	 	{
	 	 	Name = 'Registry'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Removable Storage (Success) - Inclusion'
	 	{
	 	 	Name = 'Removable Storage'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Removable Storage (Failure) - Inclusion'
	 	{
	 	 	Name = 'Removable Storage'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Central Access Policy Staging (Success) - Inclusion'
	 	{
	 	 	Name = 'Central Policy Staging'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Central Access Policy Staging (Failure) - Inclusion'
	 	{
	 	 	Name = 'Central Policy Staging'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Audit Policy Change (Success) - Inclusion'
	 	{
	 	 	Name = 'Audit Policy Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Audit Policy Change (Failure) - Inclusion'
	 	{
	 	 	Name = 'Audit Policy Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Authentication Policy Change - Inclusion'
	 	{
	 	 	Name = 'Authentication Policy Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

	 	AuditPolicySubcategory 'Audit Authorization Policy Change (Success) - Inclusion'
	 	{
	 	 	Name = 'Authorization Policy Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Authorization Policy Change (Failure) - Inclusion'
	 	{
	 	 	Name = 'Authorization Policy Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Sensitive Privilege Use (Success) - Inclusion'
	 	{
	 	 	Name = 'Sensitive Privilege Use'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Sensitive Privilege Use (Failure) - Inclusion'
	 	{
	 	 	Name = 'Sensitive Privilege Use'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit IPsec Driver (Success) - Inclusion'
	 	{
	 	 	Name = 'IPsec Driver'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit IPsec Driver (Failure) - Inclusion'
	 	{
	 	 	Name = 'IPsec Driver'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Security State Change (Success) - Inclusion'
	 	{
	 	 	Name = 'Security State Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Security State Change (Failure) - Inclusion'
	 	{
	 	 	Name = 'Security State Change'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit Security System Extension (Success) - Inclusion'
	 	{
	 	 	Name = 'Security System Extension'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit Security System Extension (Failure) - Inclusion'
	 	{
	 	 	Name = 'Security System Extension'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	AuditPolicySubcategory 'Audit System Integrity (Success) - Inclusion'
	 	{
	 	 	Name = 'System Integrity'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Success'

	 	}

 	 	AuditPolicySubcategory 'Audit System Integrity (Failure) - Inclusion'
	 	{
	 	 	Name = 'System Integrity'
	 	 	Ensure = 'Present'
	 	 	AuditFlag = 'Failure'

	 	}

	 	Service 'Services(INF): simptcp'
	 	{
	 	 	Name = 'simptcp'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): W32Time'
	 	{
	 	 	Name = 'W32Time'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): SCardSvr'
	 	{
	 	 	Name = 'SCardSvr'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): SCPolicySvc'
	 	{
	 	 	Name = 'SCPolicySvc'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): NetTcpPortSharing'
	 	{
	 	 	Name = 'NetTcpPortSharing'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): DNS'
	 	{
	 	 	Name = 'DNS'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): upnphost'
	 	{
	 	 	Name = 'upnphost'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): RemoteAccess'
	 	{
	 	 	Name = 'RemoteAccess'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): DFSR'
	 	{
	 	 	Name = 'DFSR'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): Dnscache'
	 	{
	 	 	Name = 'Dnscache'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): ftpsvc'
	 	{
	 	 	Name = 'ftpsvc'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): WerSvc'
	 	{
	 	 	Name = 'WerSvc'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): Netlogon'
	 	{
	 	 	Name = 'Netlogon'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): SSDPSRV'
	 	{
	 	 	Name = 'SSDPSRV'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): Fax'
	 	{
	 	 	Name = 'Fax'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): Browser'
	 	{
	 	 	Name = 'Browser'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): NTDS'
	 	{
	 	 	Name = 'NTDS'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): gpsvc'
	 	{
	 	 	Name = 'gpsvc'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): p2pimsvc'
	 	{
	 	 	Name = 'p2pimsvc'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): TlntSvr'
	 	{
	 	 	Name = 'TlntSvr'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): SharedAccess'
	 	{
	 	 	Name = 'SharedAccess'
	 	 	State = 'Stopped'

	 	}

	 	Service 'Services(INF): Kdc'
	 	{
	 	 	Name = 'Kdc'
	 	 	State = 'Running'

	 	}

	 	Service 'Services(INF): IsmServ'
	 	{
	 	 	Name = 'IsmServ'
	 	 	State = 'Running'

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\ScRemoveOption'
	 	{
	 	 	ValueName = 'ScRemoveOption'
	 	 	ValueType = 'String'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	ValueData = '1'

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\SCENoApplyLegacyAuditPolicy'
	 	{
	 	 	ValueName = 'SCENoApplyLegacyAuditPolicy'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\KeepAliveTime'
	 	{
	 	 	ValueName = 'KeepAliveTime'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters'
	 	 	ValueData = 300000

	 	}

	 	Registry 'Registry(INF): HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\SafeDllSearchMode'
	 	{
	 	 	ValueName = 'SafeDllSearchMode'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\InactivityTimeoutSecs'
	 	{
	 	 	ValueName = 'InactivityTimeoutSecs'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 900

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\RequireSecuritySignature'
	 	{
	 	 	ValueName = 'RequireSecuritySignature'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths\Machine'
	 	{
	 	 	ValueName = 'Machine'
	 	 	ValueType = 'MultiString'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths'
	 	 	ValueData = @('Software\Microsoft\Windows NT\CurrentVersion\Print Software\Microsoft\Windows NT\CurrentVersion\Windows System\CurrentControlSet\Control\Print\Printers System\CurrentControlSet\Services\Eventlog Software\Microsoft\OLAP Server System\CurrentControlSet\Control\ContentIndex System\CurrentControlSet\Control\Terminal Server System\CurrentControlSet\Control\Terminal Server\UserConfig System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration Software\Microsoft\Windows NT\CurrentVersion\Perflib System\CurrentControlSet\Services\SysmonLog'
	 	 	)

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\EnableSecuritySignature'
	 	{
	 	 	ValueName = 'EnableSecuritySignature'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableUIADesktopToggle'
	 	{
	 	 	ValueName = 'EnableUIADesktopToggle'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\RequireStrongKey'
	 	{
	 	 	ValueName = 'RequireStrongKey'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip6\Parameters\TcpMaxDataRetransmissions'
	 	{
	 	 	ValueName = 'TcpMaxDataRetransmissions'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip6\Parameters'
	 	 	ValueData = 3

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeCaption'
	 	{
	 	 	ValueName = 'LegalNoticeCaption'
	 	 	ValueType = 'String'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 'DoD Notice and Consent Banner"  "US Department of Defense Warning Statement'

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\EnableICMPRedirect'
	 	{
	 	 	ValueName = 'EnableICMPRedirect'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA'
	 	{
	 	 	ValueName = 'EnableLUA'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop'
	 	{
	 	 	ValueName = 'PromptOnSecureDesktop'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\SmbServerNameHardeningLevel'
	 	{
	 	 	ValueName = 'SmbServerNameHardeningLevel'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0\NTLMMinClientSec'
	 	{
	 	 	ValueName = 'NTLMMinClientSec'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0'
	 	 	ValueData = 537395200

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\NullSessionShares'
	 	{
	 	 	ValueName = 'NullSessionShares'
	 	 	ValueType = 'MultiString'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = ''

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\SignSecureChannel'
	 	{
	 	 	ValueName = 'SignSecureChannel'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\CrashOnAuditFail'
	 	{
	 	 	ValueName = 'CrashOnAuditFail'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\FilterAdministratorToken'
	 	{
	 	 	ValueName = 'FilterAdministratorToken'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\EnableSecuritySignature'
	 	{
	 	 	ValueName = 'EnableSecuritySignature'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Session Manager\SubSystems\optional'
	 	{
	 	 	ValueName = 'optional'
	 	 	ValueType = 'MultiString'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Session Manager\SubSystems'
	 	 	ValueData = ''

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin'
	 	{
	 	 	ValueName = 'ConsentPromptBehaviorAdmin'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 4

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\UseMachineId'
	 	{
	 	 	ValueName = 'UseMachineId'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\TcpMaxDataRetransmissions'
	 	{
	 	 	ValueName = 'TcpMaxDataRetransmissions'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters'
	 	 	ValueData = 3

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ShutdownWithoutLogon'
	 	{
	 	 	ValueName = 'ShutdownWithoutLogon'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\RequireSecuritySignature'
	 	{
	 	 	ValueName = 'RequireSecuritySignature'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\RefusePasswordChange'
	 	{
	 	 	ValueName = 'RefusePasswordChange'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\RestrictNullSessAccess'
	 	{
	 	 	ValueName = 'RestrictNullSessAccess'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\NullSessionPipes'
	 	{
	 	 	ValueName = 'NullSessionPipes'
	 	 	ValueType = 'MultiString'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 'lsarpc netlogon samr'

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableCAD'
	 	{
	 	 	ValueName = 'DisableCAD'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\pku2u\AllowOnlineID'
	 	{
	 	 	ValueName = 'AllowOnlineID'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\pku2u'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip6\Parameters\DisableIPSourceRouting'
	 	{
	 	 	ValueName = 'DisableIPSourceRouting'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip6\Parameters'
	 	 	ValueData = 2

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0\NTLMMinServerSec'
	 	{
	 	 	ValueName = 'NTLMMinServerSec'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0'
	 	 	ValueData = 537395200

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUserName'
	 	{
	 	 	ValueName = 'DontDisplayLastUserName'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\ScreenSaverGracePeriod'
	 	{
	 	 	ValueName = 'ScreenSaverGracePeriod'
	 	 	ValueType = 'String'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	ValueData = '5'

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableSecureUIAPaths'
	 	{
	 	 	ValueName = 'EnableSecureUIAPaths'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\SupportedEncryptionTypes'
	 	{
	 	 	ValueName = 'SupportedEncryptionTypes'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
	 	 	ValueData = 2147483644

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\EnableForcedLogOff'
	 	{
	 	 	ValueName = 'EnableForcedLogOff'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers\AddPrinterDrivers'
	 	{
	 	 	ValueName = 'AddPrinterDrivers'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableInstallerDetection'
	 	{
	 	 	ValueName = 'EnableInstallerDetection'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\MaximumPasswordAge'
	 	{
	 	 	ValueName = 'MaximumPasswordAge'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 30

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\PerformRouterDiscovery'
	 	{
	 	 	ValueName = 'PerformRouterDiscovery'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\IPSEC\NoDefaultExempt'
	 	{
	 	 	ValueName = 'NoDefaultExempt'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\IPSEC'
	 	 	ValueData = 3

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\MaxDevicePasswordFailedAttempts'
	 	{
	 	 	ValueName = 'MaxDevicePasswordFailedAttempts'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 10

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AllocateDASD'
	 	{
	 	 	ValueName = 'AllocateDASD'
	 	 	ValueType = 'String'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	ValueData = '0'

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableVirtualization'
	 	{
	 	 	ValueName = 'EnableVirtualization'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\SealSecureChannel'
	 	{
	 	 	ValueName = 'SealSecureChannel'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\DisablePasswordChange'
	 	{
	 	 	ValueName = 'DisablePasswordChange'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\AuditBaseObjects'
	 	{
	 	 	ValueName = 'AuditBaseObjects'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse'
	 	{
	 	 	ValueName = 'LimitBlankPasswordUse'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers\AuthenticodeEnabled'
	 	{
	 	 	ValueName = 'AuthenticodeEnabled'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\DisableIPSourceRouting'
	 	{
	 	 	ValueName = 'DisableIPSourceRouting'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters'
	 	 	ValueData = 2

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\NTDS\Parameters\LDAPServerIntegrity'
	 	{
	 	 	ValueName = 'LDAPServerIntegrity'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\NTDS\Parameters'
	 	 	ValueData = 2

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\LmCompatibilityLevel'
	 	{
	 	 	ValueName = 'LmCompatibilityLevel'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 5

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\DisableDomainCreds'
	 	{
	 	 	ValueName = 'DisableDomainCreds'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\EnablePlainTextPassword'
	 	{
	 	 	ValueName = 'EnablePlainTextPassword'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LDAP\LDAPClientIntegrity'
	 	{
	 	 	ValueName = 'LDAPClientIntegrity'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LDAP'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Policies\Microsoft\Cryptography\ForceKeyProtection'
	 	{
	 	 	ValueName = 'ForceKeyProtection'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Policies\Microsoft\Cryptography'
	 	 	ValueData = 2

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Session Manager\ProtectionMode'
	 	{
	 	 	ValueName = 'ProtectionMode'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Session Manager'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\ForceGuest'
	 	{
	 	 	ValueName = 'ForceGuest'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\PasswordExpiryWarning'
	 	{
	 	 	ValueName = 'PasswordExpiryWarning'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	ValueData = 14

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\CachedLogonsCount'
	 	{
	 	 	ValueName = 'CachedLogonsCount'
	 	 	ValueType = 'String'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	ValueData = '4'

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\Enabled'
	 	{
	 	 	ValueName = 'Enabled'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon'
	 	{
	 	 	ValueName = 'AutoAdminLogon'
	 	 	ValueType = 'String'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	ValueData = '0'

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\RequireSignOrSeal'
	 	{
	 	 	ValueName = 'RequireSignOrSeal'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ValidateAdminCodeSignatures'
	 	{
	 	 	ValueName = 'ValidateAdminCodeSignatures'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole\SetCommand'
	 	{
	 	 	ValueName = 'SetCommand'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths\Machine'
	 	{
	 	 	ValueName = 'Machine'
	 	 	ValueType = 'MultiString'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths'
	 	 	ValueData = @('System\CurrentControlSet\Control\ProductOptions System\CurrentControlSet\Control\Server Applications Software\Microsoft\Windows NT\CurrentVersion'
	 	 	)

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\FullPrivilegeAuditing'
	 	{
	 	 	ValueName = 'FullPrivilegeAuditing'
	 	 	ValueType = 'Binary'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = @(0
	 	 	)

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM'
	 	{
	 	 	ValueName = 'RestrictAnonymousSAM'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect'
	 	{
	 	 	ValueName = 'AutoDisconnect'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
	 	 	ValueData = 15

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\NoLMHash'
	 	{
	 	 	ValueName = 'NoLMHash'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security\WarningLevel'
	 	{
	 	 	ValueName = 'WarningLevel'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security'
	 	 	ValueData = 90

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole\SecurityLevel'
	 	{
	 	 	ValueName = 'SecurityLevel'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\RestrictAnonymous'
	 	{
	 	 	ValueName = 'RestrictAnonymous'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netbt\Parameters\NoNameReleaseOnDemand'
	 	{
	 	 	ValueName = 'NoNameReleaseOnDemand'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Services\Netbt\Parameters'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeText'
	 	{
	 	 	ValueName = 'LegalNoticeText'
	 	 	ValueType = 'MultiString'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 'You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only. By using this IS (which includes any device attached to this IS)" " you consent to the following conditions: -The USG routinely intercepts and monitors communications on this IS for purposes including" " but not limited to" " penetration testing" " COMSEC monitoring" " network operations and defense" " personnel misconduct (PM)" " law enforcement (LE)" " and counterintelligence (CI) investigations. -At any time" " the USG may inspect and seize data stored on this IS. -Communications using" " or data stored on" " this IS are not private" " are subject to routine monitoring" " interception" " and search" " and may be disclosed or used for any USG-authorized purpose. -This IS includes security measures (e.g." " authentication and access controls) to protect USG interests--not for your personal benefit or privacy. -Notwithstanding the above" " using this IS does not constitute consent to PM" " LE or CI investigative searching or monitoring of the content of privileged communications" " or work product" " related to personal representation or services by attorneys" " psychotherapists" " or clergy" " and their assistants.  Such communications and work product are private and confidential.  See User Agreement for details.'

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0\allownullsessionfallback'
	 	{
	 	 	ValueName = 'allownullsessionfallback'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\EveryoneIncludesAnonymous'
	 	{
	 	 	ValueName = 'EveryoneIncludesAnonymous'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
	 	 	ValueData = 0

	 	}

	 	Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Session Manager\Kernel\ObCaseInsensitive'
	 	{
	 	 	ValueName = 'ObCaseInsensitive'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Kernel'
	 	 	ValueData = 1

	 	}

	 	Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorUser'
	 	{
	 	 	ValueName = 'ConsentPromptBehaviorUser'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
	 	 	ValueData = 0

	 	}

	 	ACL 'ACL(INF): C:\WINDOWS\System32\winevt\Logs\Application.evtx'
	 	{
	 	 	Path = 'C:\WINDOWS\System32\winevt\Logs\Application.evtx'
	 	 	DACLString = 'D:PAR(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;FA;;;S-1-5-80-880578595-1860270145-482643319-2788375705-1540778122)'

	 	}

	 	ACL 'ACL(INF): C:\WINDOWS\System32\winevt\Logs\System.evtx'
	 	{
	 	 	Path = 'C:\WINDOWS\System32\winevt\Logs\System.evtx'
	 	 	DACLString = 'D:PAR(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;FA;;;S-1-5-80-880578595-1860270145-482643319-2788375705-1540778122)'

	 	}

	 	ACL 'ACL(INF): C:\WINDOWS\System32\eventvwr.exe'
	 	{
	 	 	Path = 'C:\WINDOWS\System32\eventvwr.exe'
	 	 	DACLString = 'D:PAR(A;OICI;0x1200a9;;;S-1-15-2-1)(A;OICI;0x1200a9;;;SY)(A;OICI;0x1200a9;;;BA)(A;OICI;0x1200a9;;;BU)(A;OICI;FA;;;S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464)'

	 	}

	 	ACL 'ACL(INF): C:\WINDOWS'
	 	{
	 	 	Path = 'C:\WINDOWS'
	 	 	DACLString = 'D:PAR(A;OICIIO;FA;;;BA)(A;OICIIO;FA;;;CO)(A;OICIIO;FA;;;SY)(A;OICI;0x1200a9;;;BU)(A;OICI;0x1200a9;;;S-1-15-2-1)(A;CI;FA;;;S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464)(A;;0x1301bf;;;SY)(A;;0x1301bf;;;BA)'

	 	}

	 	ACL 'ACL(INF): C:\Program Files (x86)'
	 	{
	 	 	Path = 'C:\Program Files (x86)'
	 	 	DACLString = 'D:PAR(A;OICIIO;FA;;;BA)(A;;0x1301bf;;;BA)(A;OICI;0x1200a9;;;S-1-15-2-1)(A;OICIIO;FA;;;CO)(A;OICIIO;FA;;;SY)(A;;0x1301bf;;;SY)(A;CI;FA;;;S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464)(A;OICI;0x1200a9;;;BU)'

	 	}

	 	ACL 'ACL(INF): C:\Program Files'
	 	{
	 	 	Path = 'C:\Program Files'
	 	 	DACLString = 'D:PAR(A;OICIIO;FA;;;BA)(A;OICIIO;FA;;;CO)(A;OICIIO;FA;;;SY)(A;OICI;0x1200a9;;;BU)(A;OICI;0x1200a9;;;S-1-15-2-1)(A;CI;FA;;;S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464)(A;;0x1301bf;;;BA)(A;;0x1301bf;;;SY)'

	 	}

	 	ACL 'ACL(INF): C:\'
	 	{
	 	 	Path = 'C:\'
	 	 	DACLString = 'D:PAR(A;OICIIO;FA;;;CO)(A;CIIO;0x100002;;;BU)(A;CI;0x100004;;;BU)(A;OICI;FA;;;BA)(A;OICI;FA;;;SY)(A;OICI;0x1200a9;;;BU)'

	 	}

	 	ACL 'ACL(INF): C:\WINDOWS\System32\winevt\Logs\Security.evtx'
	 	{
	 	 	Path = 'C:\WINDOWS\System32\winevt\Logs\Security.evtx'
	 	 	DACLString = 'D:PAR(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;FA;;;S-1-5-80-880578595-1860270145-482643319-2788375705-1540778122)'

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Load_and_unload_device_drivers'
	 	{
	 	 	Policy = 'Load_and_unload_device_drivers'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Impersonate_a_client_after_authentication'
	 	{
	 	 	Policy = 'Impersonate_a_client_after_authentication'
	 	 	Identity = @('*S-1-5-6', '*S-1-5-20', '*S-1-5-19', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Change_the_system_time'
	 	{
	 	 	Policy = 'Change_the_system_time'
	 	 	Identity = @('*S-1-5-19', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Take_ownership_of_files_or_other_objects'
	 	{
	 	 	Policy = 'Take_ownership_of_files_or_other_objects'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Manage_auditing_and_security_log'
	 	{
	 	 	Policy = 'Manage_auditing_and_security_log'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Deny_log_on_as_a_batch_job'
	 	{
	 	 	Policy = 'Deny_log_on_as_a_batch_job'
	 	 	Identity = @('*S-1-5-32-546'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Back_up_files_and_directories'
	 	{
	 	 	Policy = 'Back_up_files_and_directories'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Allow_log_on_through_Remote_Desktop_Services'
	 	{
	 	 	Policy = 'Allow_log_on_through_Remote_Desktop_Services'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Enable_computer_and_user_accounts_to_be_trusted_for_delegation'
	 	{
	 	 	Policy = 'Enable_computer_and_user_accounts_to_be_trusted_for_delegation'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Create_symbolic_links'
	 	{
	 	 	Policy = 'Create_symbolic_links'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Modify_an_object_label'
	 	{
	 	 	Policy = 'Modify_an_object_label'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Access_this_computer_from_the_network'
	 	{
	 	 	Policy = 'Access_this_computer_from_the_network'
	 	 	Identity = @('*S-1-5-9', '*S-1-5-11', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Debug_programs'
	 	{
	 	 	Policy = 'Debug_programs'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Deny_log_on_through_Remote_Desktop_Services'
	 	{
	 	 	Policy = 'Deny_log_on_through_Remote_Desktop_Services'
	 	 	Identity = @('*S-1-5-32-546'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Lock_pages_in_memory'
	 	{
	 	 	Policy = 'Lock_pages_in_memory'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Increase_scheduling_priority'
	 	{
	 	 	Policy = 'Increase_scheduling_priority'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Shut_down_the_system'
	 	{
	 	 	Policy = 'Shut_down_the_system'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Add_workstations_to_domain'
	 	{
	 	 	Policy = 'Add_workstations_to_domain'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Deny_log_on_locally'
	 	{
	 	 	Policy = 'Deny_log_on_locally'
	 	 	Identity = @('*S-1-5-32-546'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Log_on_as_a_batch_job'
	 	{
	 	 	Policy = 'Log_on_as_a_batch_job'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Change_the_time_zone'
	 	{
	 	 	Policy = 'Change_the_time_zone'
	 	 	Identity = @('*S-1-5-19', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Profile_single_process'
	 	{
	 	 	Policy = 'Profile_single_process'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Allow_log_on_locally'
	 	{
	 	 	Policy = 'Allow_log_on_locally'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Create_a_pagefile'
	 	{
	 	 	Policy = 'Create_a_pagefile'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Restore_files_and_directories'
	 	{
	 	 	Policy = 'Restore_files_and_directories'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Create_a_token_object'
	 	{
	 	 	Policy = 'Create_a_token_object'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Create_permanent_shared_objects'
	 	{
	 	 	Policy = 'Create_permanent_shared_objects'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Profile_system_performance'
	 	{
	 	 	Policy = 'Profile_system_performance'
	 	 	Identity = @('*S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Create_global_objects'
	 	{
	 	 	Policy = 'Create_global_objects'
	 	 	Identity = @('*S-1-5-6', '*S-1-5-20', '*S-1-5-19', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Synchronize_directory_service_data'
	 	{
	 	 	Policy = 'Synchronize_directory_service_data'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Adjust_memory_quotas_for_a_process'
	 	{
	 	 	Policy = 'Adjust_memory_quotas_for_a_process'
	 	 	Identity = @('*S-1-5-20', '*S-1-5-19', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Deny_log_on_as_a_service'
	 	{
	 	 	Policy = 'Deny_log_on_as_a_service'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Replace_a_process_level_token'
	 	{
	 	 	Policy = 'Replace_a_process_level_token'
	 	 	Identity = @('*S-1-5-20', '*S-1-5-19'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Deny_access_to_this_computer_from_the_network'
	 	{
	 	 	Policy = 'Deny_access_to_this_computer_from_the_network'
	 	 	Identity = @('*S-1-5-32-546'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Force_shutdown_from_a_remote_system'
	 	{
	 	 	Policy = 'Force_shutdown_from_a_remote_system'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Perform_volume_maintenance_tasks'
	 	{
	 	 	Policy = 'Perform_volume_maintenance_tasks'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Act_as_part_of_the_operating_system'
	 	{
	 	 	Policy = 'Act_as_part_of_the_operating_system'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Generate_security_audits'
	 	{
	 	 	Policy = 'Generate_security_audits'
	 	 	Identity = @('*S-1-5-20', '*S-1-5-19'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Access_Credential_Manager_as_a_trusted_caller'
	 	{
	 	 	Policy = 'Access_Credential_Manager_as_a_trusted_caller'
	 	 	Identity = @(''
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Modify_firmware_environment_values'
	 	{
	 	 	Policy = 'Modify_firmware_environment_values'
	 	 	Identity = @('*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Increase_a_process_working_set'
	 	{
	 	 	Policy = 'Increase_a_process_working_set'
	 	 	Identity = @('*S-1-5-90-0', '*S-1-5-19', '*S-1-5-32-544'
	 	 	)

	 	}

	 	UserRightsAssignment 'UserRightsAssignment(INF): Bypass_traverse_checking'
	 	{
	 	 	Policy = 'Bypass_traverse_checking'
	 	 	Identity = @('*S-1-5-90-0', '*S-1-5-20', '*S-1-5-19', '*S-1-5-11', '*S-1-5-32-544'
	 	 	)

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MaxTicketAge'
	 	{
	 	 	Name = 'MaxTicketAge'
	 	 	MaxTicketAge = 10

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MaxServiceAge'
	 	{
	 	 	Name = 'MaxServiceAge'
	 	 	MaxServiceAge = 600

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MaxClockSkew'
	 	{
	 	 	Name = 'MaxClockSkew'
	 	 	MaxClockSkew = 5

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MaxRenewAge'
	 	{
	 	 	MaxRenewAge = 7
	 	 	Name = 'MaxRenewAge'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): TicketValidateClient'
	 	{
	 	 	Name = 'TicketValidateClient'
	 	 	TicketValidateClient = 1

	 	}

	 	ACL 'ACL(INF): HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg'
	 	{
	 	 	Path = 'HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg'
	 	 	DACLString = 'D:PAR(A;CI;KA;;;BA)(A;CI;KR;;;BO)(A;CI;KR;;;S-1-5-19)'

	 	}

	 	ACL 'ACL(INF): HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components'
	 	{
	 	 	Path = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components'
	 	 	DACLString = 'D:PAR(A;CI;KA;;;BA)(A;CIIO;KA;;;CO)(A;CI;KA;;;SY)(A;CI;KR;;;BU)(A;CI;KR;;;S-1-15-2-1)'

	 	}

	 	ACL 'ACL(INF): HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	{
	 	 	Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
	 	 	DACLString = 'D:PAR(A;CI;KA;;;BA)(A;CIIO;KA;;;CO)(A;CI;KA;;;SY)(A;CI;KR;;;BU)(A;CI;KR;;;S-1-15-2-1)'

	 	}

	 	ACL 'ACL(INF): HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components'
	 	{
	 	 	Path = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components'
	 	 	DACLString = 'D:PAR(A;CI;KA;;;BA)(A;CIIO;KA;;;CO)(A;CI;KA;;;SY)(A;CI;KR;;;BU)(A;CI;KR;;;S-1-15-2-1)'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): NewGuestName'
	 	{
	 	 	NewGuestName = 'parasite'
	 	 	Name = 'NewGuestName'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): PasswordHistorySize'
	 	{
	 	 	PasswordHistorySize = 5
	 	 	Name = 'PasswordHistorySize'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MinimumPasswordLength'
	 	{
	 	 	Name = 'MinimumPasswordLength'
	 	 	MinimumPasswordLength = 14

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MinimumPasswordAge'
	 	{
	 	 	Name = 'MinimumPasswordAge'
	 	 	MinimumPasswordAge = 1

	 	}

	 	SecuritySetting 'SecuritySetting(INF): ForceLogoffWhenHourExpire'
	 	{
	 	 	Name = 'ForceLogoffWhenHourExpire'
	 	 	ForceLogoffWhenHourExpire = 1

	 	}

	 	SecuritySetting 'SecuritySetting(INF): LSAAnonymousNameLookup'
	 	{
	 	 	LSAAnonymousNameLookup = 0
	 	 	Name = 'LSAAnonymousNameLookup'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): ResetLockoutCount'
	 	{
	 	 	Name = 'ResetLockoutCount'
	 	 	ResetLockoutCount = 60

	 	}

	 	SecuritySetting 'SecuritySetting(INF): MaximumPasswordAge'
	 	{
	 	 	Name = 'MaximumPasswordAge'
	 	 	MaximumPasswordAge = 60

	 	}

	 	SecuritySetting 'SecuritySetting(INF): ClearTextPassword'
	 	{
	 	 	ClearTextPassword = 0
	 	 	Name = 'ClearTextPassword'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): LockoutBadCount'
	 	{
	 	 	LockoutBadCount = 3
	 	 	Name = 'LockoutBadCount'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): LockoutDuration'
	 	{
	 	 	LockoutDuration = -1
	 	 	Name = 'LockoutDuration'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): NewAdministratorName'
	 	{
	 	 	NewAdministratorName = 'thechief'
	 	 	Name = 'NewAdministratorName'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): EnableGuestAccount'
	 	{
	 	 	EnableGuestAccount = 0
	 	 	Name = 'EnableGuestAccount'

	 	}

	 	SecuritySetting 'SecuritySetting(INF): PasswordComplexity'
	 	{
	 	 	Name = 'PasswordComplexity'
	 	 	PasswordComplexity = 1

	 	}

	 	Registry 'Registry(XML): HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config\EventLogFlags'
	 	{
	 	 	ValueName = 'EventLogFlags'
	 	 	ValueType = 'Dword'
	 	 	Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config'
	 	 	ValueData = 2

	 	}

	}
}
DSCFromGPO -OutputPath 'C:\Users\robreed\Documents\WindowsPowerShell\Projects\BaselineMangement\src\Output'
