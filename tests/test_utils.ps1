Function Get-ParentItem
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Filter,

        [Parameter()]
        [switch]$Directory = $false,

        [Parameter()]
        [switch]$File = $false,

        [Parameter()]
        [switch]$Recurse = $false,

        [Parameter()]
        [switch]$FindFirst = $true
    )

    $item = Get-Item $Path
    if ($item -is [System.IO.FileInfo]) { $current = (Get-Item $item).Directory.FullName }
    elseif ($item -is [System.IO.DirectoryInfo]) { $current = (Get-Item $item).Parent.FullName }
    else { return $null }

    $searchItems = Get-ChildItem -Path $current -Filter $Filter -Directory:$Directory -File:$File

    if ($searchItems -ne $Null -and $FindFirst)
    {
        return $searchItems
    }
    elseif ($Recurse -and !([string]::IsNullOrEmpty($current)))
    {
        $PSBoundParameters.Remove("Path") | Out-Null
        $PSBoundParameters.Add("Path", $current)
        Get-ParentItem @PSBoundParameters
    }
}