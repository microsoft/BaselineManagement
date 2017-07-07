Function Write-SCMAuditXMLData
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]   
        [System.Xml.XmlElement]$DiscoveryData,

        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$ValueData
    )
    
    # Grab the ExistensialRule and Validation Rule.            
    $ExistensialRule = $valueData.SelectNodes("..").ExistentialRule
    $ValidationRules = $valueData.SelectNodes("..").ValidationRules
    
    $Comments = Get-NodeComments -Node $DiscoveryData
    $Name = $DiscoveryData.SelectNodes("../..").Name
    $Name = "$((Get-NodeDataFromComments -Comments $Comments).'CCEID-50'): $Name"
            
    # Grab the Value and Operator
    $TempValue = $ValidationRules.SettingRule.Value.ValueA
    $Operator = $ValidationRules.SettingRule.Operator

    $retHash = @{}
    $retHash.AuditFlag = ""
    $retHash.Name = ""
        
    $AuditFlag = ((("$($TempValue)" -replace "[^\u0020-\u007E]", "") -replace "Success And Failure", "SuccessAndFailure") -replace "No Auditing", "NoAuditing")
    $AuditID = $DiscoveryData.AdvancedAuditDiscoveryInfo.advancedauditsettingid.Trim("{").TrimEnd("}")

    if ($AuditSubCategoryHash.ContainsKey($AuditID))
    {
        $retHash.Name = $AuditSubCategoryHash["$AuditID"]
    }
    else
    {
        Write-Error "Cannot parse Subcategory for $AuditID with AuditFlag ($AuditFlag)"
        return ""
    }

    if (![string]::IsNullOrEmpty($AuditFlag))
    {
        $retHash.AuditFlag = $AuditFlag    
    }
    
    switch ($retHash.AuditFlag)
    {
        "SuccessAndFailure" 
        {
            $retHash.AuditFlag = "Success"
            $retHash.Ensure = "Present"
            $duplicate = $retHash.Clone()
            $duplicate.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Success)" -Type AuditPolicySubcategory -Parameters $retHash -Comment $Comments
            Write-DSCString -Resource -Name "$Name (Failure)" -Type AuditPolicySubcategory -Parameters $duplicate -Comment $Comments
        }
        
        "NoAuditing" 
        {
            $retHash.Ensure = "Absent"
            $retHash.AuditFlag = "Success"
            $duplicate = $retHash.Clone()
            $duplicate.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Success)" -Type AuditPolicySubcategory -Parameters $retHash -Comment $Comments
            Write-DSCString -Resource -Name "$Name (Failure)" -Type AuditPolicySubcategory -Parameters $duplicate -Comment $Comments
        } 

        Default
        {
            $retHash.Ensure = "Present"
            Write-DSCString -Resource -Name $Name -Type AuditPolicySubcategory -Parameters $retHash -Comment $Comments
        }
    }
}
