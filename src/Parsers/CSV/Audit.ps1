Function Write-AuditCSVData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $AuditData
    )

    if (!$AuditSubCategoryHash.ContainsKey($AuditData.DataSourceKey.TrimStart("{").TrimEnd("}")))
    {
        Write-Warning "Cannot find Audit Policy for ($($AuditData.DataSourceKey)) from ($($AuditData.Name))"
        return ""
    }
    else
    {
        $Category = $AuditSubCategoryHash[$AuditData.DataSourceKey.TrimStart("{").TrimEnd("}")]
        $AuditData.ExpectedValue = ($AuditData.ExpectedValue -replace "Success And Failure", "SuccessAndFailure") -replace "No Auditing", "NoAuditing"
            
        $policyHash = @{}
        $policyHash.AuditFlag = $AuditData.ExpectedValue
        $policyHash.Name = $Category 
            
        switch ($policyHash.AuditFlag)
        {
            "SuccessAndFailure" 
            {
                $policyHash.Ensure = "Present"
                $policyHash.AuditFlag = "Success"
                $Duplicate = $policyHash.Clone()
                $Duplicate.AuditFlag = "Failure"
                Write-DSCString -Resource -Type AuditPolicySubCategory -Name "$($AuditData.CCEID): $($AuditData.Name) (Success)" -Parameters $policyHash -DoubleQuoted
                Write-DSCString -Resource -Type AuditPolicySubCategory -Name "$($AuditData.CCEID): $($AuditData.Name) (Failure)" -Parameters $Duplicate -DoubleQuoted
            }
            
            "NoAuditing" 
            {
                $policyHash.Ensure = "Absent"
                $policyHash.AuditFlag = "Success"
                $Duplicate = $policyHash.Clone()
                $Duplicate.AuditFlag = "Failure"
                Write-DSCString -Resource -Type AuditPolicySubcategory -Name "$($AuditData.CCEID): $($AuditData.Name) (Success)" -Parameters $policyHash -DoubleQuoted
                Write-DSCString -Resource -Type AuditPolicySubcategory -Name "$($AuditData.CCEID): $($AuditData.Name) (Failure)" -Parameters $Duplicate -DoubleQuoted
            } 

            Default
            {
                Write-DSCString -Resource -Type AuditPolicySubcategory -Name "$($AuditData.CCEID): $($AuditData.Name)" -Parameters $policyHash -DoubleQuoted
            }
        }
    }
}
