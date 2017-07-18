#region GPO Parsers
Function Convert-ToRepetitionString
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [int]$miRnutes
    )

    $timeSpan = New-Object System.TimeSpan -ArgumentList 0, 0, 0, $minutes
    $interval = "P"
    if ($timeSpan.Days -gt 0)
    {
        $interval += "DT" + $timeSpan.Days
    }
    if ($timeSpan.Hours -gt 0)
    {
        $interval += "H" + $timeSpan.Hours
    }

    if ($timeSpan.Minutes -gt 0)
    {
        $interval += "M" + $timeSpan.Minutes
    }

    if ($timeSpan.Seconds -gt 0)
    {
        $interval += "S" + $timeSpan.Seconds
    }
}

Function Test-BoolOrNull
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [AllowNull()]
        $Value
    )

    if ($Value -ne $Null)
    {
        return [bool]$Value
    }
    else
    {
        return $null
    }
}

Function Remove-EmptyValues
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $hashtable
    )
    $keys = $hashtable.keys.Clone()
    foreach ($key in $keys)
    {
            if ($hashtable[$key] -is [System.Collections.Hashtable])
            {
                Remove-EmptyValues -hashtable $hashtable[$key]
                if ($hashtable[$key].Keys.Where({$_ -ne "EmbeddedInstance"}).Count -eq 0)
                {
                    $hashtable.Remove($key)
                }
            }
            elseif ($hashtable[$key] -is [System.Array])
            {
                $goodEntries = @()
                for ($i = 0; $i -lt $hashtable[$key].Count; $i++)
                {
                    if ($hashtable[$key][$i] -is [System.Collections.Hashtable])
                    {
                        Remove-EmptyValues -hashtable $hashtable[$key][$i]
                        if ($hashtable[$key][$i].Keys.Where({$_ -ne "EmbeddedInstance"}).count -gt 0)
                        {
                            $goodEntries += $i
                        }
                    }
                    else 
                    {
                        $goodEntries += $i
                    }
                }

                $hashtable[$key] = $hashtable[$key][$goodEntries]
            }
            else
            {
                if ($hashtable[$key] -eq $null)
                {
                    $hashtable.Remove($key)
                }
            }
    }
}

Function Write-GPOScheduledTasksXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )

    $schTaskHash = @{}
    $Properties = $XML.Properties
    # Set up Task Triggers if necessary
    switch -regex ($XML.LocalName)
    {
        "^(Task|ImmediateTask)$"
        {
            $schTaskHash.Name = $Properties.Name
            $schTaskHash.Path = "\DSC\"
            
            $actions = @{
                EmbeddedInstance = "TaskAction"
                Execute          = $Properties.appName
                WorkingDirectory = $Properties.startIn
                Arguments        = $Properties.args
            }
            $schTaskHash.TaskAction = $actions
            
            if ($Properties.runAs)
            {
                $principal = @{
                    EmbeddedInstance = "TaskUserPrincipal"
                    UserID           = $Properties.runAs
                    RunLevel         = @("Highest", "Limited")[$Properties.systemRequired]
                }
                $schTaskHash.TaskUserPrincipal = $principal
            }

            $settings = @{
                EmbeddedInstance           = "TaskSettingsSet"
                Enabled                    = Test-BoolOrNull $Properties.enabled
                RunOnIdle                  = Test-BoolOrNull $Properties.startOnlyIfIdle
                ExecutionTimeLimit         = (Convert-ToRepetitionString -minutes $Properties.maxRunTime)
                IdleSetting                = @{
                    EmbeddedInstance = "IdleSetting"
                    StopOnIdleEnd    = Test-BoolOrNull $Properties.stopOnIdleEnd
                }
                StopIfGoingOnBatteries     = Test-BoolOrNull $Properties.stopIfGoingOnBatteries
                DisallowStartIfOnBatteries = Test-BoolOrNull $Properties.noStartIfOnBatteries
            }
            $schTaskHash.TaskSettingsSet = $settings

            if ($_ -eq "ImmediateTask")
            {
                $schTaskHash.TaskTriggers = @(
                    @{
                        EmbeddedInstance = "TaskTriggers"
                        Id = "ImmediateTask Trigger($($schTaskHash.Name)): $(New-Guid)"
                        StartBoundary    = (Get-Date).AddMinutes(15)
                    }
                )
                break
            }

            $triggers = @()
            
            foreach ($t in $Properties.Triggers.ChildNodes)
            {
                $tmpHash = @{}
                switch ($t.Type)
                {
                    'IDLE'
                    {

                    }
                    'ONCE'
                    {
                        
                    }
                    'STARTUP'
                    {

                    }
                    'LOGON'
                    {

                    }
                    'DAILY'
                    {
                        if ($t.Interval)
                        {
                            $tmpHash.DaysInterval = $t.interval
                        }
                    }
                    'WEEKLY'
                    {
                        if ($t.Interval)
                        {
                            $tmpHash.WeeksInterval = $t.interval
                        }

                        if ($t.week)
                        {
                            # MUST be FIRST, SECOND, THIRD, FOURTH, or LAST to indicate the week position in the month when the task executes.
                            Write-Warning "Write-GPOScheduledTaskXMLData: Week of Month interval is not supported in DSC Resource"
                        }
                    }
                    'MONTHLY'
                    {
                        if ($t.months)
                        {
                            # BIT MASK: MUST map to the month in which a job will process. The field is a 12-bit mask with 1 assigned to January, 2 to February, 4 to March, 8 to April, 16 to May, 32 to June, 64 to July, 128 to August, 256 to September, 512 to October, 1024 to November, and 2048 to December.
                            Write-Warning "Write-GPOScheduledTaskXMLData: MONTHS interval is not supported in DSC Resource"
                        }
                    }
                }

                if ($t.hasEndDate)
                {
                    $tmpHash.EndBoundary = Get-Date -Day $t.endDay -Month $t.endMonth -Year $t.endYear
                }

                $tmpHash.DaysOfWeek = 0 # MUST map to the day of the week in which the job will process for jobs that execute on a selected day. The field is a bit mask with 1 assigned to Sunday, 2 to Monday, 4 to Tuesday, 8 to Wednesday, 16 to Thursday, 32 to Friday, and 64 to Saturday.
                
                $tmpHash.StartBoundary = Get-Date -Year $t.beginYear -Month $t.beginMonth -Day $t.beginDay -Hour $t.startHour -Minute $t.startMinutes
                
                if ($t.repeatTask)
                {
                    $duration = Convert-ToRepetitionString -minutes $t.minutesDuration
                    $interval = Convert-ToRepetitionString -minutes $t.minutesInterval
                    
                    $tmpHash.TaskRepetition = @{
                        EmbeddedInstance  = "TaskRepetition"
                        Interval          = $interval
                        Duration          = $duration
                        StopAtDurationEnd = $t.killAtDurationEnd
                    }
                }
                
                $tmpHash.EmbeddedInstance = "TaskTriggers"
                $tmpHash.Enabled = $True
                $tmpHash.Id = "$($t.Type) Trigger($($schTaskHash.Name)): $(New-Guid)"
                $triggers += $tmpHash
            }

            $schTaskHash.TaskTriggers = $triggers
        }

        "^(Task|ImmediateTask)V2$"
        {
            $schTaskHash.Name = $XML.Name
            $schTaskHash.Path = "\DSC\"
            
            $schTaskHash.TaskAction = @()
            foreach ($a in $Properties.Task.Actions.ChildNodes)
            {
                if ($a.LocalName -eq "Exec")
                {
                    $tmpAction = @{
                        EmbeddedInstance = "TaskAction"
                        Execute          = $a.Command
                        WorkingDirectory = $a.WorkingDirectory
                        Arguments        = $a.Arguments
                    }
                    $schTaskHash.TaskAction += $tmpAction
                }
            }

            if ($Properties.Task.Principals.Count -gt 0)
            {
                foreach ($p in $Properties.Task.Prinicpals.ChildNodes)
                {
                    $principal = @{
                        EmbeddedInstance = "TaskUserPrincipal"
                        UserId           = $p.UserId
                        LogonType        = $p.logonType
                        RunLevel         = $p.runLevel
                    }
                    break
                }
                $schTaskHash.TaskUserPrincipal = $principal
            }
            elseif ($Properties.runAs)
            {
                $principal = @{
                    EmbeddedInstance = "TaskUserPrincipal"
                    UserID           = $Properties.runAs
                    LogonType        = $Properties.logonType
                }
                
                if ($Properties.systemRequired)
                {
                    $principal.RunLevel = @("Highest", "Limited")[$Properties.systemRequired]
                }
                
                $schTaskHash.TaskUserPrincipal = $principal
            }

            $settings = @{
                EmbeddedInstance           = "TaskSettingsSet"
                MultipleInstances          = $Properties.Task.Settings.MultipleInstancePolicy
                
                Enabled                    = Test-BoolOrNull $Properties.Task.Settings.enabled
                RunOnIdle                  = Test-BoolOrNull $Properties.Task.Settings.runOnlyIfIdle
                ExecutionTimeLimit         = $Properties.Task.Settings.executionTimeLimit
                Priority                   = $Properties.Task.Settings.Priority
                WakeToRun                  = Test-BoolOrNull $Properties.Task.Settings.WakeToRun
                Hidden                     = Test-BoolOrNull $Properties.Task.Settings.Hidden
                AllowDemandStart           = Test-BoolOrNull $Properties.Task.Settings.AllowStartOnDemand
                AllowHardTerminate         = Test-BoolOrNull $Properties.Task.Settings.AllowHardTerminate
                StartWhenAvailable         = Test-BoolOrNull $Properties.Task.Settings.StartWhenAvailable
                RunOnlyIfNetworkAvailable  = Test-BoolOrNull $Properties.Task.Settings.RunOnlyIfNetworkAvailable
                
                IdleSetting                = @{
                    EmbeddedInstance = "IdleSetting"
                    StopOnIdleEnd    = Test-BoolOrNull $Properties.Task.Settings.IdleSettings.StopOnIdleEnd
                    IdleDuration     = $Properties.Task.Settings.IdleSettings.Duration
                    WaitTimeOut      = $Properties.Task.Settings.IdleSettings.WaitTimeOut
                    RestartOnIdle    = Test-BoolOrNull $Properties.Task.Settings.IdleSettings.RestartOnIdle
                }

                RestartCount               = $Properties.Task.Settings.RestartOnFailure.Count
                RestartInterval            = $Properties.Task.Settings.RestartOnFailure.Interval
                StopIfGoingOnBatteries     = Test-BoolOrNull $Properties.Task.Settings.stopIfGoingOnBatteries
                DisallowStartIfOnBatteries = Test-BoolOrNull $Properties.Task.Settings.DisallowStartIfOnBatteries
            }
            $schTaskHash.TaskSettingsSet = $settings

            if ($_ -eq "ImmediateTaskV2")
            {
                $schTaskHash.TaskTriggers = @(
                    @{
                        Id = "ImmediateTask Trigger($($schTaskHash.Name)): $(New-Guid)"
                        EmbeddedInstance = "TaskTriggers"
                        StartBoundary    = (Get-Date).AddMinutes(15)
                    }
                )
                break
            }

            $triggers = @()
            foreach ($t in $Properties.Task.Triggers.ChildNodes)
            {
                $tmpHash = @{}
                switch -regex ($t.Name)
                {
                    "(BootTrigger|EventTrigger|IdleTrigger|RegistrationTrigger|SessionStateChangeTrigger)"
                    {
                        Write-Warning "Write-GPOScheduledTaskXMLData: $_ Trigger type is not yet suppported."
                        break
                    }
                    
                    "LogonTrigger"
                    {
                        $tmpHash.UserId = $t.UserId
                    }

                    "CalendarTrigger"
                    {
                        switch ($t.ChildNodes.Name)
                        {
                            "ScheduleByDay"
                            {
                                $tmpHash.DaysInterval = $t.ScheduleByDay.DaysInterval
                            }

                            "ScheduleByWeek"
                            {
                                $tmpHash.WeeksInterval = $t.ScheduleByWeek.WeeksInterval
                            }
                            
                            "StartBoundary"
                            {
                                $tmpHash.StartBoundary = $t.StartBoundary
                            }

                            "Enabled"
                            {
                                $tmpHash.Enabled = Test-BoolOrNull $t.Enabled  
                            }

                            Default
                            {
                                Write-Warning "Write-GPOScheduledTaskXMLData:$_ Trigger Type is not supported."
                            }
                        }
                    }

                    ".*"
                    {
                        $tmpHash.Enabled = Test-BoolOrNull $t.Enabled
                        $tmpHash.Id = "$_ Trigger ($($schTaskHash.Name)): $(New-Guid)"   
                        $tmpHash.StartBoundary = $t.StartBoundary
                        $tmpHash.EndBoundary = $t.EndBoundary
                        $tmpHash.Delay = $t.Delay
                        $tmpHash.ExecutionTimeLimit = $t.ExecutionTimeLimit
                        $tmpHash.TaskRepetition = @{
                            EmbeddedInstance  = "TaskRepetition"
                            Interval          = $t.Repetition.Interval
                            Duration          = $t.Repetition.Interval
                            StopAtDurationEnd = Test-BoolOrNull $t.Repetition.StopAtDurationEnd
                        }
                        $tmpHash.EmbeddedInstance = "TaskTriggers"
                    }
                }                

                $triggers += $tmpHash
            }
            
            $schTaskHash.TaskTriggers = $triggers
#region Old Task Trigger method            
            <#foreach ($t in $Properties.Task.Triggers.CalendarTrigger)
            {
                $tmpHash = @{}
                $tmpHash.StartBoundary = $t.StartBoundary
                $tmpHash.EndBoundary = $t.EndBoundary
                $tmpHash.Enabled = $t.Enabled   

                # Create Repetition embedded instance.
                $tmpHash.TaskRepetition = @{
                    EmbeddedInstance = "TaskRepetition"
                    Interval         = $t.Repetition.Interval
                    Duration         = $t.Repetition.Interval
                    StopAtDurationEnd = $t.Repetition.StopAtDurationEnd
                }

                # Are there more ?

                $tmpHash.EmbeddedInstance = "TaskTriggers"
                $triggers += $tmpHash
            }

            foreach ($t in $Properties.Task.Triggers.BootTrigger)
            {
                $tmpHash = @{}
                $tmpHash.Enabled = $t.Enabled   
                # Are there more ?

                $tmpHash.TaskRepetition = @{
                    EmbeddedInstance  = "TaskRepetition"
                    Interval          = $t.Repetition.Interval
                    Duration          = $t.Repetition.Interval
                    StopAtDurationEnd = $t.Repetition.StopAtDurationEnd
                }
                
                $tmpHash.EmbeddedInstance = "TaskTriggers"
                $triggers += $tmpHash
            }

            foreach ($t in $Properties.Task.Triggers.LogonTrigger)
            {
                $tmpHash = @{}
                $tmpHash.Enabled = $t.Enabled   

                # Are there more ?

                $tmpHash.TaskRepetition = @{
                    EmbeddedInstance  = "TaskRepetition"
                    Interval          = $t.Repetition.Interval
                    Duration          = $t.Repetition.Interval
                    StopAtDurationEnd = $t.Repetition.StopAtDurationEnd
                }
                
                $tmpHash.EmbeddedInstance = "TaskTriggers"
                $triggers += $tmpHash
            }
            
            foreach ($t in $Properties.Task.Triggers.RegistrationTrigger)
            {
                $tmpHash = @{}
                $tmpHash.Enabled = $t.Enabled   

                # Are there more ?

                $tmpHash.TaskRepetition = @{
                    EmbeddedInstance  = "TaskRepetition"
                    Interval          = $t.Repetition.Interval
                    Duration          = $t.Repetition.Interval
                    StopAtDurationEnd = $t.Repetition.StopAtDurationEnd
                }
                
                $tmpHash.EmbeddedInstance = "TaskTriggers"
                $triggers += $tmpHash
            }
            
            foreach ($t in $Properties.Task.Triggers.SessionStateChangeTrigger)
            {
                $tmpHash = @{}
                $tmpHash.Enabled = $t.Enabled   

                # Are there more ?

                $tmpHash.TaskRepetition = @{
                    EmbeddedInstance  = "TaskRepetition"
                    Interval          = $t.Repetition.Interval
                    Duration          = $t.Repetition.Interval
                    StopAtDurationEnd = $t.Repetition.StopAtDurationEnd
                }
                
                $tmpHash.EmbeddedInstance = "TaskTriggers"
                $triggers += $tmpHash
            }#>
#endregion
        }

        Default
        {
            Write-Warning "Write-GPOScheduledTaskXMLData:$_ task type is not implemented"
        }
    }

    Remove-EmptyValues -hashtable $schTaskHash
    Write-DSCString -Resource -Type xScheduledTask -Name "ScheduledTask(XML): $($schTaskHash.Name)" -Parameters $schTaskHash
}
#endregion