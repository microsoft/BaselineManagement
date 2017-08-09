$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Networking Common Modules
Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetworkingDsc.Common' `
                                                     -ChildPath 'NetworkingDsc.Common.psm1'))

# Import the Networking Resource Helper Module
Import-Module -Name (Join-Path -Path $modulePath `
                               -ChildPath (Join-Path -Path 'NetworkingDsc.ResourceHelper' `
                                                     -ChildPath 'NetworkingDsc.ResourceHelper.psm1'))

# Import Localization Strings
$localizedData = Get-LocalizedData `
    -ResourceName 'MSFT_xNetworkTeam' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)

<#
    .SYNOPSIS
    Returns the current state of a Network Team.

    .PARAMETER Name
    Specifies the name of the network team to create.

    .PARAMETER TeamMembers
    Specifies the network interfaces that should be a part of the network team.
    This is a comma-separated list.
#>
Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [String[]]
        $TeamMembers
    )

    $configuration = @{
        name        = $Name
        teamMembers = $TeamMembers
    }

    Write-Verbose -Message ($localizedData.GetTeamInfo -f $Name)
    $networkTeam = Get-NetLBFOTeam -Name $Name -ErrorAction SilentlyContinue

    if ($networkTeam)
    {
        Write-Verbose -Message ($localizedData.FoundTeam -f $Name)
        if ($null -eq (Compare-Object -ReferenceObject $TeamMembers -DifferenceObject $networkTeam.Members))
        {
            Write-Verbose -Message ($localizedData.teamMembersExist -f $Name)
            $configuration.Add('loadBalancingAlgorithm', $networkTeam.loadBalancingAlgorithm)
            $configuration.Add('teamingMode', $networkTeam.teamingMode)
            $configuration.Add('ensure','Present')
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.TeamNotFound -f $Name)
        $configuration.Add('ensure','Absent')
    }

    return $configuration
}

<#
    .SYNOPSIS
    Adds, updates or removes a Network Team.

    .PARAMETER Name
    Specifies the name of the network team to create.

    .PARAMETER TeamMembers
    Specifies the network interfaces that should be a part of the network team.
    This is a comma-separated list.

    .PARAMETER TeamingMode
    Specifies the teaming mode configuration.

    .PARAMETER LoadBalancingAlgorithm
    Specifies the load balancing algorithm for the network team.

    .PARAMETER Ensure
    Specifies if the network team should be created or deleted.
#>
Function Set-TargetResource
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [String[]]
        $TeamMembers,

        [Parameter()]
        [ValidateSet("SwitchIndependent", "LACP", "Static")]
        [String]
        $TeamingMode = "SwitchIndependent",

        [Parameter()]
        [ValidateSet("Dynamic", "HyperVPort", "IPAddresses", "MacAddresses", "TransportPorts")]
        [String]
        $LoadBalancingAlgorithm = "HyperVPort",

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )
    Write-Verbose -Message ($localizedData.GetTeamInfo -f $Name)
    $networkTeam = Get-NetLBFOTeam -Name $Name -ErrorAction SilentlyContinue

    if ($Ensure -eq 'Present')
    {
        if ($networkTeam)
        {
            Write-Verbose -Message ($localizedData.foundTeam -f $Name)
            $setArguments = @{
                'name' = $Name
            }

            if ($networkTeam.loadBalancingAlgorithm -ne $LoadBalancingAlgorithm)
            {
                Write-Verbose -Message ($localizedData.lbAlgoDifferent -f $LoadBalancingAlgorithm)
                $setArguments.Add('loadBalancingAlgorithm', $LoadBalancingAlgorithm)
                $isNetModifyRequired = $true
            }

            if ($networkTeam.TeamingMode -ne $TeamingMode)
            {
                Write-Verbose -Message ($localizedData.teamingModeDifferent -f $TeamingMode)
                $setArguments.Add('teamingMode', $TeamingMode)
                $isNetModifyRequired = $true
            }

            if ($isNetModifyRequired)
            {
                Write-Verbose -Message ($localizedData.modifyTeam -f $Name)
                Set-NetLbfoTeam @setArguments -ErrorAction Stop -Confirm:$false
            }

            $netTeamMembers = Compare-Object `
                            -ReferenceObject $TeamMembers `
                            -DifferenceObject $networkTeam.Members
            if ($null -ne $netTeamMembers)
            {
                Write-Verbose -Message ($localizedData.membersDifferent -f $Name)
                $membersToRemove = ($netTeamMembers | Where-Object {$_.SideIndicator -eq '=>'}).InputObject
                if ($membersToRemove)
                {
                    Write-Verbose -Message ($localizedData.removingMembers -f ($membersToRemove -join ','))
                    $null = Remove-NetLbfoTeamMember -Name $membersToRemove `
                                                    -Team $Name `
                                                    -ErrorAction Stop `
                                                    -Confirm:$false
                }

                $membersToAdd = ($netTeamMembers | Where-Object {$_.SideIndicator -eq '<='}).InputObject
                if ($membersToAdd)
                {
                    Write-Verbose -Message ($localizedData.addingMembers -f ($membersToAdd -join ','))
                    $null = Add-NetLbfoTeamMember -Name $membersToAdd `
                                        -Team $Name `
                                        -ErrorAction Stop `
                                        -Confirm:$false
                }
            }

        }
        else
        {
            Write-Verbose -Message ($localizedData.createTeam -f $Name)
            try
            {
                $null = New-NetLbfoTeam `
                            -Name $Name `
                            -TeamMembers $teamMembers `
                            -TeamingMode $TeamingMode `
                            -LoadBalancingAlgorithm $loadBalancingAlgorithm `
                            -ErrorAction Stop `
                            -Confirm:$false
                Write-Verbose -Message $localizedData.createdNetTeam
            }

            catch
            {
                    $errorId = 'TeamCreateError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                    $errorMessage = $localizedData.failedToCreateTeam
                    $exception = New-Object -TypeName System.InvalidOperationException `
                                            -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                                            -ArgumentList $exception, $errorId, $errorCategory, $null

                    $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.removeTeam -f $Name)
        $null = Remove-NetLbfoTeam -Name $name -ErrorAction Stop -Confirm:$false
    }
}

<#
    .SYNOPSIS
    Tests is a specified Network Team is in the correct state.

    .PARAMETER Name
    Specifies the name of the network team to create.

    .PARAMETER TeamMembers
    Specifies the network interfaces that should be a part of the network team.
    This is a comma-separated list.

    .PARAMETER TeamingMode
    Specifies the teaming mode configuration.

    .PARAMETER LoadBalancingAlgorithm
    Specifies the load balancing algorithm for the network team.

    .PARAMETER Ensure
    Specifies if the network team should be created or deleted.
#>
Function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [String[]]
        $TeamMembers,

        [Parameter()]
        [ValidateSet("SwitchIndependent", "LACP", "Static")]
        [String]
        $TeamingMode = "SwitchIndependent",

        [Parameter()]
        [ValidateSet("Dynamic", "HyperVPort", "IPAddresses", "MacAddresses", "TransportPorts")]
        [String]
        $LoadBalancingAlgorithm = "HyperVPort",

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ($localizedData.GetTeamInfo -f $Name)
    $networkTeam = Get-NetLbfoTeam -Name $Name -ErrorAction SilentlyContinue

    if ($ensure -eq 'Present')
    {
        if ($networkTeam)
        {
            Write-Verbose -Message ($localizedData.foundTeam -f $Name)
            if (
                ($networkTeam.LoadBalancingAlgorithm -eq $LoadBalancingAlgorithm) -and
                ($networkTeam.teamingMode -eq $TeamingMode) -and
                ($null -eq (Compare-Object -ReferenceObject $TeamMembers -DifferenceObject $networkTeam.Members))
            )
            {
                Write-Verbose -Message ($localizedData.teamExistsNoAction -f $Name)
                return $true
            }
            else
            {
                Write-Verbose -Message ($localizedData.teamExistsWithDifferentConfig -f $Name)
                return $false
            }
        }
        else
        {
            Write-Verbose -Message ($localizedData.teamDoesNotExistShouldCreate -f $Name)
            return $false
        }
    }
    else
    {
        if ($networkTeam)
        {
            Write-Verbose -Message ($localizedData.teamExistsShouldRemove -f $Name)
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.teamDoesNotExistNoAction -f $Name)
            return $true
        }
    }
}
