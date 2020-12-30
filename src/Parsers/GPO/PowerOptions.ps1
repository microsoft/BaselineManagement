#region GPO Parsers

$PowerPlanXML = @{
    "requireWakePwd" = "CONSOLELOCK"
    "turnOffHD" = "DISKIDLE"
    "sleepAfter" = "STANDBYIDLE"
    "allowHybridSleep" = "HYBRIDSLEEP"
    "hibernate" = "HIBERNATEIDLE"
    "lidClose" = "LIDACTION"
    "pbAction"  = "PBUTTONACTION"
    "strtMenuAction" = "UIBUTTON_ACTION"
    "linkPwrMgmt" = "ASPM"
    "procStateMin" = "PROCTHROTTLEMIN1" # Not sure about this one.
    "procStateMax" = "PROCTHROTTLEMAX1" # Not sure about this one.
    "adaptive" = "VIDEOADAPT"
    "displayOff" = "VIDEOIDLE"
    "critBatAction" = "BATACTIONCRIT"
    "lowBatteryLvl" = "BATLEVELLOW"
    "critBatteryLvl" = "BATLEVELCRIT"
    "lowBatteryNot" ="BATFLAGSLOW"
    "lowBatteryAction" = "BATACTIONLOW"
}

$PowerSchemeXML = @{
    "monitor" = "VIDEOIDLE"
    "hardDisk" = "DISKIDLE"
    "standbyAc" = "STANDBYIDLE"
    "hibernate" = "HIBERNATEIDLE"
}

$PowerGUIDS = @{
    'SCHEME_BALANCED' = '381b4222-f694-41f0-9685-ff5bb260df2e'
    'CONSOLELOCK' = '0e796bdb-100d-47d6-a2d5-f7d2daa51f51'
    'DEVICEIDLE' = '4faab71a-92e5-4726-b531-224559672d19'  
    'WIFIINSTANDBY' = 'f15576e8-98b7-4186-b944-eafa664402d9'
    'SUB_DISK' = 'f15576e8-98b7-4186-b944-eafa664402d9'
    'DISKMAXPOWER' = '51dea550-bb38-4bc4-991b-eacf37be5ec8'
    'DISKIDLE' = '6738e2c4-e8a5-4a42-b16a-e040e769756e'
    'DISKBURSTIGNORE' = '80e3c60e-bb94-4ad8-bbe0-0d3195efc663'
    'SUB_SLEEP' = '12bbebe6-58d6-4636-95bb-3217ef867c1a'
    'AWAYMODE' = '25dfa149-5dd1-4736-b5ab-e8a37b5b8187'
    'STANDBYIDLE' = '29f6c1db-86da-48c5-9fdb-f2b67b1f44da'
    'UNATTENDSLEEP' = '7bc4a2f9-d8fc-4469-b07b-33eb785aaca0'
    'HYBRIDSLEEP' = '94ac6d29-73ce-41a6-809f-6363ba21b47e'
    'HIBERNATEIDLE' = '9d7815a6-7ee4-497e-8888-515a05f02364'
    'SYSTEMREQUIRED' = 'a4b195f5-8225-47d8-8012-9d41369786e2'
    'ALLOWSTANDBY' = 'abfc2519-3608-4c2a-94ea-171b0ed546ab'
    'RTCWAKE' = 'bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d'
    'REMOTEFILESLEEP' = 'd4c1d4c8-d5cc-43d3-b83e-fc51215cb04d'
    'SUB_IR' = 'd4e98f31-5ffe-4ce1-be31-1b38b384c009'
    'EXECTIME' = '3166bc41-7e98-4e03-b34e-ec0f5f2b218e'
    'COALTIME' = 'c36f0eb4-2988-4a70-8eee-0884fc2c2433'
    'PROCIR' = 'c42b79aa-aa3a-484b-a98f-2cf32aa90a28'
    'DEEPSLEEP' = 'd502f7ee-1dc7-4efd-a55d-f04b6f5c0545'
    'SUB_INTSTEER' = '3619c3f2-afb2-4afc-b0e9-e7fef372de36'
    'MODE' = '2bfc24f9-5ea2-4801-8213-3dbae01aa39d'
    'PERPROCLOAD' = '73cde64d-d720-4bb2-a860-c755afe77ef2'
    'UNPARKTIME' = 'd6ba4903-386f-4c2c-8adb-5c21b3328d25'
    'SUB_BUTTONS' = 'd6ba4903-386f-4c2c-8adb-5c21b3328d25'
    'LIDACTION' = '5ca83367-6e45-459f-a27b-476b1d01c936'
    'PBUTTONACTION' = '7648efa3-dd9c-4e3e-b566-50f929386280'
    'SHUTDOWN' = '833a6b62-dfa4-46d1-82f8-e09e34d029d6'
    'SBUTTONACTION' = '96996bc0-ad50-47ec-923b-6f41874dd9eb'
    'UIBUTTON_ACTION' = 'a7066653-8d6c-40a8-910e-a1f54b84c7e5'
    'SUB_PCIEXPRESS' = 'a7066653-8d6c-40a8-910e-a1f54b84c7e5'
    'ASPM' = 'ee12f906-d277-404b-b6da-e5fa1a576df5'
    'SUB_PROCESSOR' = '332f614f-c023-47bd-a74d-324c7fe0ae2c'
    'PERFINCTHRESHOLD' = '06cadf0e-64ed-448a-8927-ce7bf90eb35d'
    'PERFINCTHRESHOLD1' = '06cadf0e-64ed-448a-8927-ce7bf90eb35e'
    'CPMINCORES' = '0cc5b647-c1df-4637-891a-dec35c318583'
    'CPMINCORES1' = '0cc5b647-c1df-4637-891a-dec35c318584'
    'PERFDECTHRESHOLD' = '12a0ab44-fe28-4fa9-b3bd-4b64f44960a6'
    'PERFDECTHRESHOLD1' = '12a0ab44-fe28-4fa9-b3bd-4b64f44960a7'
    'HETEROCLASS1INITIALPERF' = '1facfc65-a930-4bc5-9f38-504ec097bbc0'
    'CPCONCURRENCY' = '2430ab6f-a520-44a2-9601-f7f23b5134b1'
    'CPINCREASETIME' = '2ddd5a84-5a71-437e-912a-db0b8c788732'
    'PERFEPP' = '36687f9e-e3a5-4dbf-b1dc-15eb381c6863'
    'THROTTLING' = '3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb'
    'HETEROINCREASETIME' = '4009efa7-e72d-4cba-9edf-91084ea8cbc3'
    'PERFDECPOL' = '40fbefc7-2e9d-4d25-a185-0cfd8574bac6'
    'PERFDECPOL1' = '40fbefc7-2e9d-4d25-a185-0cfd8574bac7'
    'CPPERF' = '447235c7-6a8d-4cc0-8e24-9eaf70b96e2b'
    'CPPERF1' = '447235c7-6a8d-4cc0-8e24-9eaf70b96e2c'
    'PERFBOOSTPOL' = '45bcc044-d885-43e2-8605-ee0ec6e96b59'
    'PERFINCPOL' = '465e1f50-b610-473a-ab58-00d1077dc418'
    'PERFINCPOL1' = '465e1f50-b610-473a-ab58-00d1077dc419'
    'IDLEDEMOTE' = '4b92d758-5a24-4851-a470-815d78aee119'
    'CPDISTRIBUTION' = '4bdaf4e9-d103-46d7-a5f0-6280121616ef'
    'PERFCHECK' = '4d2b0152-7d5c-498b-88e2-34345392a2c5'
    'PERFDUTYCYCLING' = '4e4450b3-6179-4e91-b8f1-5bb9938f81a1'
    'IDLEDISABLE' = '5d76a2ca-e8c0-402f-a133-2158492d58ad'
    'LATENCYHINTUNPARK' = '616cdaa5-695e-4545-97ad-97dc2d1bdd88'
    'LATENCYHINTUNPARK1' = '616cdaa5-695e-4545-97ad-97dc2d1bdd89'
    'LATENCYHINTPERF' = '619b7505-003b-4e82-b7a6-4dd29c300971'
    'LATENCYHINTPERF1' = '619b7505-003b-4e82-b7a6-4dd29c300972'
    'CPDECREASE' = '68dd2f27-a4ce-4e11-8487-3794e4135dfa'
    'IDLESCALING' = '6c2993b0-8f48-481f-bcc6-00dd2742aa06'
    'CPDECREASEPOL' = '71021b41-c749-4d21-be74-a00f335d582b'
    'IDLEPROMOTE' = '7b224883-b3cc-4d79-819f-8374152cbe7c'
    'PERFHISTORY' = '7d24baa7-0b84-480f-840c-1b0743c00f5f'
    'PERFHISTORY1' = '7d24baa7-0b84-480f-840c-1b0743c00f60'
    'HETERODECREASETIME' = '7f2492b6-60b1-45e5-ae55-773f8cd5caec'
    'HETEROPOLICY' = '7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5'
    'PROCTHROTTLEMIN' = '893dee8e-2bef-41e0-89c6-b55d0929964c'
    'PROCTHROTTLEMIN1' = '893dee8e-2bef-41e0-89c6-b55d0929964d'
    'PERFAUTONOMOUS' = '8baa4a8a-14c6-4451-8e8b-14bdbd197537'
    'CPOVERUTIL' = '943c8cb6-6f93-4227-ad87-e9a3feec08d1'
    'SYSCOOLPOL' = '94d3a615-a899-4ac5-ae2b-e4d8f634367f'
    'PERFINCTIME' = '984cf492-3bed-4488-a8f9-4286c97bf5aa'
    'PERFINCTIME1' = '984cf492-3bed-4488-a8f9-4286c97bf5ab'
    'IDLESTATEMAX' = '9943e905-9a30-4ec1-9b99-44dd3b76f7a2'
    'HETEROINCREASETHRESHOLD' = 'b000397d-9b0b-483d-98c9-692a6060cfbf'
    'PROCTHROTTLEMAX' = 'bc5038f7-23e0-4960-96da-33abaf5935ec'
    'PROCTHROTTLEMAX1' = 'bc5038f7-23e0-4960-96da-33abaf5935ed'
    'PERFBOOSTMODE' = 'be337238-0d82-4146-a960-4f3749d470c7'
    'IDLECHECK' = 'c4581c31-89ab-4597-8e2b-9c9cab440e6b'
    'CPINCREASEPOL' = 'c7be0679-2817-4d69-9d02-519a537ed0c6'
    'PERFAUTONOMOUSWINDOW' = 'cfeda3d0-7697-4566-a922-a9086cd49dfa'
    'PERFDECTIME' = 'd8edeb9b-95cf-4f95-a73c-b061973693c8'
    'PERFDECTIME1' = 'd8edeb9b-95cf-4f95-a73c-b061973693c9'
    'CPINCREASE' = 'df142941-20f3-4edf-9a4a-9c83d3d717d1'
    'CPDECREASETIME' = 'dfd10d17-d5eb-45dd-877a-9a34ddd15c82'
    'DISTRIBUTEUTIL' = 'e0007330-f589-42ed-a401-5ddb10e785d3'
    'CPMAXCORES' = 'ea062031-0e34-4ff1-9b6d-eb1059334028'
    'CPMAXCORES1' = 'ea062031-0e34-4ff1-9b6d-eb1059334029'
    'CPHEADROOM' = 'f735a673-2066-4f80-a0c5-ddee0cf1bf5d'
    'HETERODECREASETHRESHOLD' = 'f8861c27-95e7-475c-865b-13c0cb3f9d6b'
    'HETEROCLASS0FLOORPERF' = 'fddc842b-8364-4edc-94cf-c17f60de1c80'
    'SUB_VIDEO' = 'fddc842b-8364-4edc-94cf-c17f60de1c80'
    'VIDEODIM' = '17aaa29b-8b43-4b94-aafe-35f64daaf1ee'
    'VIDEOIDLE' = '3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e'
    'VIDEOANNOY' = '82dbcf2d-cd67-40c5-bfdc-9f1a5ccd4663'
    'VIDEOCONLOCK' = '8ec4b3a5-6868-48c2-be75-4f3044be88a7'
    'VIDEOADAPT' = '90959d22-d6a1-49b9-af93-bce885ad335b'
    'ALLOWDISPLAY' = 'a9ceb8da-cd46-44fb-a98b-02af69de4623'
    'VIDEOADAPTINC' = 'eed904df-b142-4183-b10b-5a1197a37864'
    'ADAPTBRIGHT' = 'fbd9aa66-9553-4097-ba44-ed6e9d65eab8'
    'SUB_PRESENCE' = 'fbd9aa66-9553-4097-ba44-ed6e9d65eab8'
    'NSENINPUTPRETIME' = '5adbbfbc-074e-4da1-ba38-db8b36b2c8f3'
    'SUB_ENERGYSAVER' = '34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4'
    'ESBRIGHTNESS' = '13d09884-f74e-474a-a852-b6bde8ad03a8'
    'ESBATTTHRESHOLD' = 'e69653ca-cf7f-4f05-aa73-cb833fa90ad4'
    'SUB_BATTERY' = 'e69653ca-cf7f-4f05-aa73-cb833fa90ad4'
    'BATACTIONCRIT' = '637ea02f-bbcb-4015-8e2c-a1c7b9c0b546'
    'BATLEVELLOW' = '8183ba9a-e910-48da-8769-14ae6dc1170a'
    'BATLEVELCRIT' = '9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469'
    'BATFLAGSLOW' = 'bcded951-187b-4d05-bccc-f7e51960c258'
    'BATACTIONLOW' = 'd8742dcb-3e6a-4b3c-b3fe-374623cdcf06'
}

$PowerPlans = @{
    'a1841308-3541-4fab-bc81-f71556f20b4a' = 'SCHEME_MAX' 
    '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' = 'SCHEME_MIN'
    '381b4222-f694-41f0-9685-ff5bb260df2e' = 'SCHEME_BALANCED'
}

Function Write-GPOGlobalPowerOptionsXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )

    Write-Verbose "Write-GPOGlobalPowerOptionsXMLData: Unsure of how to implement these flags as it is not specified which plan they should apply to."
    Add-ProcessingHistory -Type GlobalPowerOptions -Name "$($XML.Properties.Name)" -ParsingError
}

Function Write-GPOPowerPlanXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )

    $Properties = $XML.Properties
    
    $powerHash = @{}
    $powerHash.PlanGUID = $Properties.nameGUID
    $Name = $Properties.nameGUID
    
    if ($PowerPlans.ContainsKey($Name))
    {
        $Name = $PowerPlans[$Name]
    }

    if ($Properties.Default -eq 1)
    {
        Write-DSCString -Resource -Type cPowerPlan -Name "PowerOptions(XML): PowerPlan - ($Name)" -Parameters @{Name = $PowerPlans[$Name]; GUID = $Name; $Active = $true}
    }

    foreach ($powerSetting in $PowerXML.Keys)
    {
        $AC = $Properties.GetAttribute("$($powerSetting)AC")
        $DC = $Properties.GetAttribute("$($powerSetting)DC")
        $WriteDSC = $false
        $powerHash.SettingGuid = $PowerGUIDS[$PowerPlanXML[$powerSetting]]
        
        if ($AC -ne $Null -or $DC -ne $null)
        {
            $powerHash.Value = $AC
            $powerHash.AcDc = "Both"
            $WriteDSC = $true
        }
        elseif ($AC -ne $null)
        {
            $powerHash.Value = $AC
            $powerHash.AcDc = "AC"
            $WriteDSC = $true
        }
        elseif ($DSC -ne $null)
        {
            $powerHash.Value = $AC
            $powerHash.AcDc = "DC"
            $WriteDSC = $true
        }

        if ($WriteDSC)
        {    
            Write-DscString -Resource -Type cPowerPlanSetting -Name "PowerOptions(XML): ($Name): $($powerSetting)" -Parameters $powerHash
        }
    }
}

Function Write-GPOPowerSchemeXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML    
    )
    
    Write-Verbose "Write-GPOPowerSchemeXMLData: PowerScheme options are not fully implemented in DSC resource"

    $powerHash = @{}
    $powerHash.PlanGUID = $Properties.name
    $Name = $Properties.name

    if ($Properties.Default -eq 1)
    {
        Write-DSCString -Resource -Type cPowerPlan -Name "PowerOptions(XML): PowerPlan - ($Name)" -Parameters @{Name = $PowerPlans[$Name]; GUID = $Name; $Active = $true} -CommentOUT
    }

    foreach ($powerSetting in $PowerSchemeXML.Keys)
    {
        $AC = $Properties.GetAttribute("$($powerSetting)AC")
        $DC = $Properties.GetAttribute("$($powerSetting)DC")
        $WriteDSC = $false
        $powerHash.SettingGuid = $PowerGUIDS[$PowerSchemeXML[$powerSetting]]
        
        if ($AC -ne $Null -or $DC -ne $null)
        {
            $powerHash.Value = $AC
            $powerHash.AcDc = "Both"
            $WriteDSC = $true
        }
        elseif ($AC -ne $null)
        {
            $powerHash.Value = $AC
            $powerHash.AcDc = "AC"
            $WriteDSC = $true
        }
        elseif ($DSC -ne $null)
        {
            $powerHash.Value = $AC
            $powerHash.AcDc = "DC"
            $WriteDSC = $true
        }

        if ($WriteDSC)
        {    
            Write-DscString -Resource -Type cPowerPlanSetting -Name "PowerOptions(XML): PowerScheme - ($Name): $($powerSetting)" -Parameters $powerHash -CommentOUT
        }
    }
}
#endregion