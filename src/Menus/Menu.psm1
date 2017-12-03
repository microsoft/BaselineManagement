###############################################################################
# Simple Textbased Powershell Menu
# Author : Michael Albert
# E-Mail : info@michlstechblog.info
# License: none, feel free to modify
# usage:
# Source the menu.ps1 file in your script:
# . .\menu.ps1
# fShowMenu requieres 2 Parameters:
# Parameter 1: [string]MenuTitle
# Parameter 2: [hashtable]@{[string]"ReturnString1"=[string]"Menu Entry 1";[string]"ReturnString2"=[string]"Menu Entry 2";[string]"ReturnString3"=[string]"Menu Entry 3"
# Return     : Select String
# For example:
# fShowMenu "Choose your favorite Band" @{"sl"="Slayer";"me"="Metallica";"ex"="Exodus";"an"="Anthrax"}
# #############################################################################

function Show-Menu([System.String]$sMenuTitle,[Ref]$hMenuEntries)
{
	# Orginal Konsolenfarben zwischenspeichern
	[System.Int16]$iSavedBackgroundColor=[System.Console]::BackgroundColor
	[System.Int16]$iSavedForegroundColor=[System.Console]::ForegroundColor
	# Menu Colors
	# inverse fore- and backgroundcolor 
	[System.Int16]$iMenuForeGroundColor=[System.ConsoleColor]::White
	[System.Int16]$iMenuBackGroundColor=[System.ConsoleColor]::DarkMagenta
	[System.Int16]$iMenuBackGroundColorSelectedLine=[System.ConsoleColor]::White
	[System.Int16]$iMenuForeGroundColorSelectedLine=[System.ConsoleColor]::DarkMagenta
	# Alternative, colors
	[System.Int16]$iTitleForeGroundColor=[System.ConsoleColor]::Green
    [System.Int16]$iTitleBackGroundColor=[System.ConsoleColor]::DarkMagenta
    # Init
	[System.Int16]$iMenuStartLineAbsolute=0
	[System.Int16]$iMenuLoopCount=0
	[System.Int16]$iMenuSelectLine=1
	[System.Int16]$iMenuEntries=$hMenuEntries.Value.Count
	$hMenu=[ordered]@{};
	[Hashtable]$hMenuHotKeyList=@{};
	[Hashtable]$hMenuHotKeyListReverse=@{};
	[System.Int16]$iMenuHotKeyChar=0
	[System.String]$sValidChars=""
    [System.Console]::ForegroundColor = $iTitleForeGroundColor
    [System.Console]::BackgroundColor = $iTitleBackGroundColor
	[System.Console]::WriteLine(" "+$sMenuTitle)
	[System.Console]::ForegroundColor = $imenuForeGroundColor
    [System.Console]::BackgroundColor = $imenuBackGroundColor
    # Für die eindeutige Zuordnung Nummer -> Key
	$ydsiMenuLoopCount=1
	# Start Hotkeys mit "1"!
	$iMenuHotKeyChar=49
	foreach ($sKey in $hMenuEntries.Value.Keys){
        if ($hMenuEntries.Value.Item($sKey) -is [System.Collections.Specialized.OrderedDictionary] -or $hMenuEntries.Value.Item($sKey) -is [System.Collections.Hashtable])
        {
            if ($hMenuEntries.Value.Item($sKey).Keys.Count -gt 1)
            {
                $hMenuEntries.Value.Item($sKey).Expanded = $false
            }
        }
        
        # Hotkey zuordnung zum Menueintrag
		<#$hMenuHotKeyList.Add([System.Int16]$iMenuLoopCount,[System.Convert]::ToChar($iMenuHotKeyChar))
		$hMenuHotKeyListReverse.Add([System.Convert]::ToChar($iMenuHotKeyChar),[System.Int16]$iMenuLoopCount)
		$sValidChars+=[System.Convert]::ToChar($iMenuHotKeyChar)
		$iMenuLoopCount++
		$iMenuHotKeyChar++
		# Weiter mit Kleinbuchstaben
		if($iMenuHotKeyChar -eq 58){$iMenuHotKeyChar=97}
		# Weiter mit Großbuchstaben
		elseif($iMenuHotKeyChar -eq 123){$iMenuHotKeyChar=65}
		# Jetzt aber ende
		elseif($iMenuHotKeyChar -eq 91){
			Write-Error " Menu too big!"
			exit(99)
		}#>
	}

    if ($Host.Name -match "ISE") {return}
	# Remember Menu start
	[System.Int16]$iBufferFullOffset=0
	$iMenuStartLineAbsolute=[System.Console]::CursorTop
	do{
		$hMenu=[ordered]@{};
        $iMenuLoopCount=1
        ####### Calculate Menu #######
	    foreach ($sKey in $hMenuEntries.Value.Keys){
            
            if ($hMenuEntries.Value.Item($sKey) -is [System.Collections.Specialized.OrderedDictionary] -or $hMenuEntries.Value.Item($sKey) -is [System.Collections.Hashtable])
            {
                $hMenu.Add([System.Int16]$iMenuLoopCount, [ref]$hMenuEntries.Value.Item($skey))		
                            
                if ($hMenuEntries.Value.Item($skey).Expanded)
                {
                    foreach ($subkey in $hMenuEntries.Value.Item($skey).Keys | ?{$_ -notin "Expanded", "Title"})
                    {
                        $iMenuLoopCount++
                        $hMenu.Add([System.Int16]$iMenuLoopCount, [ref]$hMenuEntries.Value.Item($skey).Item($subkey))
                    }            
                }
            }
            else
            {
                $hMenu.Add([System.Int16]$iMenuLoopCount, $skey)		
            }
            $iMenuLoopCount++
        }        
        [System.Int16]$iMenuEntries=$hMenu.Keys.Count
        ####### Draw Menu  #######
		[System.Console]::CursorTop=($iMenuStartLineAbsolute-$iBufferFullOffset)
		[System.Console]::CursorVisible = $false
        for ($iMenuLoopCount=1;$iMenuLoopCount -le $iMenuEntries;$iMenuLoopCount++){
			[System.Console]::Write("`r")
			[System.String]$sPreMenuline=""
			#$sPreMenuline="  "+$hMenuHotKeyList[[System.Int16]$iMenuLoopCount]
			#$sPreMenuline+=": "
			if ($iMenuLoopCount -eq $iMenuSelectLine){
				[System.Console]::BackgroundColor=$iMenuBackGroundColorSelectedLine
				[System.Console]::ForegroundColor=$iMenuForeGroundColorSelectedLine
			}
			$line = ""
            if ($hMenu.Item($iMenuLoopCount) -is [ref])
            { 
                if ($hMenu.Item($iMenuLoopCount).Value.Contains("Expanded"))
                {
                    if ($hMenu.Item($iMenuLoopCount).Value.Expanded -eq $True)
                    {
                        $sPreMenuline += "[-] "    
                    }
                    else
                    {
                        $sPreMenuline += "[+] "
                    }
                }

                [System.Console]::Write($sPreMenuline+$hMenu.Item($iMenuLoopCount).Value.Title)
                $line = $sPreMenuline+$hMenu.Item($iMenuLoopCount).Value.Title
            }
            else
            {
                [System.Console]::Write($sPreMenuline+$hMenu.Item($iMenuLoopCount))
                $line = $sPreMenuline+$hMenu.Item($iMenuLoopCount)
            }
            
			[System.Console]::BackgroundColor=$iMenuBackGroundColor
			[System.Console]::ForegroundColor=$iMenuForeGroundColor
			$string = new-object System.String -ArgumentList " ", ([System.Console]::WindowWidth - $line.length)
            [System.Console]::WriteLine($string)
		}
		[System.Console]::BackgroundColor=$iMenuBackGroundColor
		[System.Console]::ForegroundColor=$iMenuForeGroundColor
        #$line = "  Your choice: "
        #$string = new-object System.String -ArgumentList " ", ([System.Console]::WindowWidth - $line.length)
		#[System.Console]::Write("  Your choice: " + $string)
        if ($Verbose)
        {
            [System.console]::Write("Top - $([system.Console]::CursorTop);WTop - $([system.Console]::WindowTop);abs - $iMenuStartLineAbsolute")
        }
		if (($iMenuStartLineAbsolute+$iMenuLoopCount) -gt [System.Console]::BufferHeight){
			$iBufferFullOffset=($iMenuStartLineAbsolute+$iMenuLoopCount)-[System.Console]::BufferHeight
		}
		
        $int = ([System.Console]::WindowTop + [System.Console]::WindowHeight) - [System.Console]::CursorTop

        $string = new-object System.String -ArgumentList " ", ([System.Console]::WindowWidth)
        $old = [System.Console]::CursorTop
        for ($i = 0; $i -lt $int; $i++)
        {
            [System.Console]::SetCursorPosition(0, $old + $i)
            if ($Verbose)
            {
                [System.Console]::Write("i = $i; int = $int")
            }
            else
            {
                [System.Console]::Write($string)
            }
        }
        [System.Console]::SetCursorPosition(0, $old)
        ####### End Menu #######
		####### Read Kex from Console 
        [System.Console]::CursorVisible = $true
		$oInputChar=[System.Console]::ReadKey($true)
		
        Switch ($oInputChar)
        {
            {[System.Int16]$_.Key -eq [System.ConsoleKey]::DownArrow}
            {
			    if ($iMenuSelectLine -lt $iMenuEntries){
				    $iMenuSelectLine++
			    }
                continue
		    }
		    
		    {[System.Int16]$_.Key -eq [System.ConsoleKey]::UpArrow}
            {
			    if ($iMenuSelectLine -gt 1){
				    $iMenuSelectLine--
			    }
                continue
		    }
             
            {[System.Int16]$_.Key -eq [System.ConsoleKey]::LeftArrow}
            {
			    if ($hMenu.Item($iMenuSelectLine) -is [ref])
                {
                    if ($hMenu.Item($iMenuSelectLine).Value.Expanded -ne $false)
                    {
                        $hMenu.Item($iMenuSelectLine).Value.Expanded = $false
                    }
                }
                Continue
		    }

            {[System.Int16]$_.Key -eq [System.ConsoleKey]::RightArrow}
            {
			    if ($hMenu.Item($iMenuSelectLine) -is [ref])
                {
                    if ($hMenu.Item($iMenuSelectLine).Value.Expanded -ne $true)
                    {
                        $hMenu.Item($iMenuSelectLine).Value.Expanded = $true
                    }
                }
                continue
		    }

            # Use this to tweak menu and trap them in for testing, remove -and $false to enable.
            {([System.Int16]$_.Key -eq [System.ConsoleKey]::Enter)}
            {
			    if ($hMenu.Item($iMenuSelectLine) -is [ref])
                {
                    if ($hMenu.Item($iMenuSelectLine).Value.Contains("Expanded"))
                    {
                        if ($hMenu.Item($iMenuSelectLine).Value.Expanded -ne $false)
                        {
                            $hMenu.Item($iMenuSelectLine).Value.Expanded = $false
                            $oInputChar = $null
                            continue
                        }
                        elseif ($hMenu.Item($iMenuSelectLine).Value.Expanded -ne $true)
                        {
                            $hMenu.Item($iMenuSelectLine).Value.Expanded = $true
                            $oInputChar = $null
                            continue
                        }
                    }
                    else
                    {
                        if ($hMenu.Item($iMenuSelectLine).Value.Title -match "<ISE>" -and ((Get-PscallStack)[1].ScriptName -notmatch "WPLUS_ISEMenu"))
                        {
                            [System.Console]::ForegroundColor=[System.ConsoleColor]::Red
                            [System.Console]::Write("The Selected Lab is designed to be run in the PowerShell ISE. Please make another selection, or reopen the Lab in the ISE")
                            [System.Console]::ForegroundColor=$iMenuForeGroundColor
                            Start-Sleep -Seconds 1
                            $oInputChar = $null
                            continue
                        }
                    }
                }
		    } 
            
            {[System.Int16]$_.Key -eq [System.ConsoleKey]::Escape}
            {
			    return
		    }

		    {[System.Char]::IsLetterOrDigit($_.KeyChar)}
            {
			    [System.Console]::Write($oInputChar.KeyChar.ToString())	
                continue
		    }
        }

        [System.Console]::BackgroundColor=$iMenuBackGroundColor
		[System.Console]::ForegroundColor=$iMenuForeGroundColor

	} while(([System.Int16]$oInputChar.Key -ne [System.ConsoleKey]::Enter) -and ($sValidChars.IndexOf($oInputChar.KeyChar) -eq -1))
	
	# reset colors
	[System.Console]::ForegroundColor=$iSavedForegroundColor
	[System.Console]::BackgroundColor=$iSavedBackgroundColor
	if($oInputChar.Key -eq [System.ConsoleKey]::Enter){
		
        if ($hMenu.Item($iMenuSelectLine) -is [ref])
        {
                return([System.String]$hMenu.Item($iMenuSelectLine).Value.Key.Trim())
        }
        else
        {
            return([System.String]$hMenu.Item($iMenuSelectLine).Trim())
        }
	}
	else{
		[System.Console]::Writeline("")
		return($hMenu[$hMenuHotKeyListReverse[$oInputChar.KeyChar]])
	}
}


<# Old Dialog box method for prompting lessons.  
    Has not been updated for tiered module approach.
#>
Function Show-Dialog
{
    Add-Type -AssemblyName System.Windows.Forms 
         Add-Type -AssemblyName System.Drawing 
  
         $form = New-Object System.Windows.Forms.Form  
         $form.Text = "Please Select a Lab" 
         $form.Size = New-Object System.Drawing.Size(300,200)  
         $form.StartPosition = "CenterScreen" 
  
         $OKButton = New-Object System.Windows.Forms.Button 
         $OKButton.Location = New-Object System.Drawing.Point(75,120) 
         $OKButton.Size = New-Object System.Drawing.Size(75,23) 
         $OKButton.Text = "OK" 
         $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK 
         $form.AcceptButton = $OKButton 
         $form.Controls.Add($OKButton) 
  
         $CancelButton = New-Object System.Windows.Forms.Button 
         $CancelButton.Location = New-Object System.Drawing.Point(150,120) 
         $CancelButton.Size = New-Object System.Drawing.Size(75,23) 
         $CancelButton.Text = "Cancel" 
         $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel 
         $form.CancelButton = $CancelButton 
         $form.Controls.Add($CancelButton) 
  
         $label = New-Object System.Windows.Forms.Label 
         $label.Location = New-Object System.Drawing.Point(10,20)  
         $label.Size = New-Object System.Drawing.Size(280,20)  
         $label.Text = "Please make a selection from the list below:" 
         $form.Controls.Add($label)  
  
         $listBox = New-Object System.Windows.Forms.Listbox  
         $listBox.Location = New-Object System.Drawing.Point(10,40)  
         $listBox.Size = New-Object System.Drawing.Size(260,20)  
     
         $lessonSelection = @()
         # Look through lab files to find Lab Title"
         for ($i=0;$i -lt $labFiles.count; $i++)
         {
             [void] $listBox.Items.Add($(Get-Content -TotalCount 1 -Path $labFiles[$i].FullName).TrimStart("# ")) 
             $lessonSelection += "lesson$($labFiles[$i].LessonNumber)"
         }
    
         $listBox.Height = 70 
         $form.Controls.Add($listBox)  
         $form.Topmost = $True 
  
         $result = $form.ShowDialog() 
  
         if ($result -eq [System.Windows.Forms.DialogResult]::OK) 
         { 
            $selection = $lessonSelection[$listBox.SelectedIndex]
            $lesson = $selection

            return $lesson
         }
         else
         {
            return
         } 
}
 