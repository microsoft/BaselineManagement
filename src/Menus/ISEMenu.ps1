$menuinputpath = Join-Path $PSScriptRoot "menu_input.txt"
if (Test-Path $menuinputpath)
{
    $menuinput = Get-Content $menuinputpath
    $Values = [ordered]@{}
    foreach ($input in $menuinput)
    {
        $Values["$input"] = $input
    }

    Import-Module $(Join-Path $PSScriptRoot "Menu.psm1") -Force
    $menuoutputpath = $(Join-Path $psscriptroot "menu_output.txt")
    Show-Menu -sMenuTitle "Select a valid Baseline" -hMenuEntries ([ref]$Values) | Out-File $menuoutputpath    
}
else
{
    Throw "No input specified!"
}