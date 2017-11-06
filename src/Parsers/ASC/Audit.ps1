Function Write-ASCAuditJSONData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        $AuditData
    )

    if (!$AuditSubCategoryHash.ContainsKey($AuditData.AuditPolicyID))
    {
        Write-Warning "Cannot find Audit Policy for ($($AuditData.AuditPolicyID)) from ($($AuditData.Name))"
        return ""
    }
    else
    {
        $Category = $AuditSubCategoryHash[$AuditData.AuditPolicyID]
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
                Write-DSCString -Resource -Type AuditPolicySubCategory -Name "$($AuditData.CCEID): $($AuditData.ruleName) (Success)" -Parameters $policyHash -CommentOUT:($AuditData.State -ne 'Enabled') -DoubleQuoted
                Write-DSCString -Resource -Type AuditPolicySubCategory -Name "$($AuditData.CCEID): $($AuditData.ruleName) (Failure)" -Parameters $Duplicate -CommentOUT:($AuditData.State -ne 'Enabled') -DoubleQuoted
            }
            
            "NoAuditing" 
            {
                $policyHash.Ensure = "Absent"
                $policyHash.AuditFlag = "Success"
                $Duplicate = $policyHash.Clone()
                $Duplicate.AuditFlag = "Failure"
                Write-DSCString -Resource -Type AuditPolicySubcategory -Name "$($AuditData.CCEID): $($AuditData.ruleName) (Success)" -Parameters $policyHash -CommentOUT:($AuditData.State -ne 'Enabled') -DoubleQuoted
                Write-DSCString -Resource -Type AuditPolicySubcategory -Name "$($AuditData.CCEID): $($AuditData.ruleName) (Failure)" -Parameters $Duplicate -CommentOUT:($AuditData.State -ne 'Enabled') -DoubleQuoted
            } 

            Default
            {
                Write-DSCString -Resource -Type AuditPolicySubcategory -Name "$($AuditData.CCEID): $($AuditData.ruleName)" -Parameters $policyHash -CommentOUT:($AuditData.State -ne 'Enabled') -DoubleQuoted
            }
        }
    }
}
