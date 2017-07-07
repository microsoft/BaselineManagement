function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Group,

        [Parameter()]
        [string[]]$Members,

        [Parameter()]
        [string[]]$MemberOf,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure
    )
    
    return @{}
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Group,

        [Parameter()]
        [string[]]$Members,

        [Parameter()]
        [string[]]$MemberOf,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure
    )

    return $true
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Group,

        [Parameter()]
        [string[]]$Members,

        [Parameter()]
        [string[]]$MemberOf,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [string]$Ensure
    )

}

Export-ModuleMember -Function *-TargetResource;