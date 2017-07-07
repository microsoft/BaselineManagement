Function Write-GPOAuditCSVData
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]$Entry
    )

    $retHash = @{}
    $retHash.Name = $Entry.SubCategory

    switch -regex ($Entry.InclusionSetting)
    {
        "Success and Failure"
        {
            $retHash.Ensure = "Present"
            $retHash.AuditFlag = "Success"
            Write-DSCString -Resource -Name "$Name (Success) - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
            $retHash.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Failure) - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
        }

        "No Auditing"
        {
            $retHash.Ensure = "Absent"
            $retHash.AuditFlag = "Success"
            Write-DSCString -Resource -Name "$Name (Success) - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
            $retHash.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Failure) - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
        }

        "^(Success|Failure)$"
        {
            $retHash.Ensure = "Present"
            $retHash.AuditFlag = $Entry.InclusionSetting
            Write-DSCString -Resource -Name "$Name - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
        }
    }
    
    $retHash.Ensure = "Absent"
    switch -regex ($Entry.ExclusionSetting)
    {
        "Success and Failure"
        {
            $retHash.Ensure = "Absent"
            $retHash.AuditFlag = "Success"
            Write-DSCString -Resource -Name "$Name (Success) - Exclusion" -Type AuditPolicySubcategory -Parameters $retHash
            $retHash.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Failure) - Exclusion" -Type AuditPolicySubcategory -Parameters $retHash
        }

        "No Auditing"
        {
            # I am not sure how to make sure that "No Auditing" is Excluded or ABSENT. What should it be set to then?
        }

        "^(Success|Failure)$"
        {
            $retHash.Ensure = "Absent"
            $retHash.AuditFlag = $Entry.ExclusionSetting
            Write-DSCString -Resource -Name "$Name - Exclusion" -Type AuditPolicySubcategory -Parameters $retHash
        }
    }
}

Function Write-GPOAuditINFData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$AuditData
    ) 

    if (!$AuditCategoryHash.ContainsKey($key))
    {
        Write-Warning "Write-INFAuditData:$Key is no longer supported or not implemented"
        return ""
    }

    $AuditFlag = "None", "Success", "Failure", "SuccessAndFailure", "None"

    foreach ($subCategory in $AuditCategoryHash[$key])
    {
        $paramHash = @{}
        $paramHash.Name = $subCategory
        switch -Regex ($AuditData)
        {
            "(0|4)" 
            { 
                $paramHash.AuditFlag = "Failure"
                $paramHash.Ensure = "Absent"
                Write-DSCString -Resource -Name "INF_Audit $($subCategory): NoAuditing(Failure)" -Type AuditPolicySubcategory -Parameters $paramHash 
                $paramHash.AuditFlag = "Success"
                $paramHash.Ensure = "Absent"
                Write-DSCString -Resource -Name "INF_Audit $($subCategory): NoAuditing(Success)" -Type AuditPolicySubcategory -Parameters $paramHash 
                return
            } 
            
            "(1|3)"
            {
                $paramHash.AuditFlag = "Success"
                Write-DSCString -Resource -Name "INF_Audit $($subCategory): Success" -Type AuditPolicySubcategory -Parameters $paramHash 
            }

            "(2|3)"
            {
                $paramHash.AuditFlag = "Failure"
                Write-DSCString -Resource -Name "INF_Audit $($subCategory): Failure" -Type AuditPolicySubcategory -Parameters $paramHash 
            }
        }
    }
}
