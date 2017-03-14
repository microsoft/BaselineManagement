Function Group-DSCOutput
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeLine = $true)]
        [string]$DSCOutput
    )

    begin
    {
        $GroupedOutput = @()
    }

    process
    {
        $DSCOutput -match "VERBOSE: \[(?<Configuration>.*)\]:\s*LCM:\s*\[\s(?<Operation>\S*)\s*(?<Stage>.*)\s\]\s*\[\[(?<Resource>.*)\](?<Name>.*)\].*"
        {
            $Matches.Remove(0)
            $GroupedOutput += [pscustomobject]$Matches
        }
    }

    end
    {
        return $GroupedOutput
    }
}