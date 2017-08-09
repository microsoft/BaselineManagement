$output = 'C:\MOF'

Configuration PowerPlan_Sample
{
    Import-DscResource -ModuleName DSCR_PowerPlan
    Node localhost
    {
        cPowerPlan PowerPlan_Sample
        {
            Ensure = "Present"
            GUID = "381b4222-f694-41f0-9685-ff5bb260df2e"
            Name = "Balanced"
            Active = $true
        }

        cPowerPlan PowerPlan_Sample2
        {
            Ensure = "Present"
            GUID = "893c34ea-563b-4217-a144-c17f69bed8aa"
            Name = "Customized Plan"
            Description = "This is Customized"
        }

        cPowerPlanSetting PowerPlanSetting_Sample
        {
            PlanGuid = 'ACTIVE'
            SettingGuid = 'PBUTTONACTION'
            Value = 2   #Hibernate
            AcDc = 'AC'
        }
    }
}

PowerPlan_Sample -OutputPath $output
Start-DscConfiguration -Path  $output -Verbose -wait

