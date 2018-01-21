$menuinputpath = Join-Path $PSScriptRoot "menu_input.txt"
if (Test-Path $menuinputpath)
{
    $menuinput = Get-Content $menuinputpath
    $Values = [ordered]@{}
    $Key = $null
    foreach ($input in $menuinput)
    {
        if ($input -notmatch "=")
        {
            $Values[$input] = [ordered]@{}
            $Values[$input].Title = $input
            $Key = $input
            continue
        }
        else
        {        
            $input = $input.TrimStart("=")
            If ($Key -ne $null)
            {
                $Values[$key][$input] = @{}
                $Values[$key][$input].Title = $input
                $Values[$key][$input].Key = "$Key|$input"
            }
            else
            {
                $Values[$input] = $input
            }
        }
    }

    Import-Module $(Join-Path $PSScriptRoot "Menu.psm1") -Force
    $menuoutputpath = $(Join-Path $psscriptroot "menu_output.txt")
    Show-Menu -sMenuTitle "Select a valid Baseline" -hMenuEntries ([ref]$Values) | Out-File $menuoutputpath    
}
else
{
    Throw "No input specified!"
}