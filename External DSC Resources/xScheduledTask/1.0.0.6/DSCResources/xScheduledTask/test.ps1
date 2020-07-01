Configuration Test
{
	Import-DscResource -ModuleName xScheduledTask
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DSCResource -ModuleName 'AuditPolicyDSC'
    Import-DSCResource -ModuleName 'SecurityPolicyDSC'
    Import-DSCResource -ModuleName 'BaselineManagement'
    Import-DSCResource -ModuleName 'xSMBShare'
    Import-DSCResource -ModuleName 'DSCR_PowerPlan'
    Import-DSCResource -ModuleName 'xScheduledTask'
    Import-DSCResource -ModuleName 'Carbon'
    Import-DSCResource -ModuleName 'PrinterManagement' 
    Import-DSCResource -ModuleName 'rsInternationalSettings'
	node localhost
	{
		xScheduledTask asd
		{
			Name = "A"
			Path = "\Microsoft\"
            TaskAction = 
						@(
							TaskAction
							        {
									    id = 1
									    Execute = "c:\1.exe"
									    WorkingDirectory = "c:\111"
									    Arguments = "arg1"
									};
							TaskAction
									{
										id = 2
										Execute = "c:\12.exe"
										WorkingDirectory = "c:\111"
										Arguments = "arg1"
									}
						)
            TaskUserPrincipal = TaskUserPrincipal
            {
                UserID =  "user1"
                LogonType = 'Interactive' # if you want to set user password do not set this you must be delete this property  in your configuration script like this   TaskUserPrincipal = TaskUserPrincipal{UserID =  "user1";RunLevel = 'Limited'}
            }
            TaskSettingsSet = TaskSettingsSet
            {
                Enabled = $true
                Hidden = $false
                RestartCount = 0
                MultipleInstances = 'IgnoreNew'
                AllowDemandStart =  $true
                RunOnlyIfNetworkAvailable = $true
				IdleSetting = IdleSetting
										{
										    IdleDuration = "PT10M"
										    RestartOnIdle = $False
										    StopOnIdleEnd = $true
										    WaitTimeout = "PT1H"
										}
            }
            NetworkSetting = NetworkSetting
            {
                Name = "hphr.com"
            } 
            TaskTriggers =
							@(
								TaskTriggers
								{
									Id = "122"
									Enabled = $true
									DaysInterval = 1
									StartBoundary ="2016-12-18T15:50:06+08:00"
									TaskRepetition =  TaskRepetition
																	{
																		Interval = 	"PT30M"
																		Duration = "P2D"
																		StopAtDurationEnd = $true
																	}
								};
								TaskTriggers
								{
									Id = "222"
									Enabled = $true
									WeeksInterval = 2
									DaysOfWeek = 127
									StartBoundary ="2016-02-18T20:50:06+08:00"
								}
							)
		}
	}
}

TEST -OutputPath P:\Temp