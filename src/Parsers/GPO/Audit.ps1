Function Write-GPOAuditOptionCSVData
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]$Entry
    )

    $Value = $Entry.'Inclusion Setting'
    $Name = $Entry.'Subcategory'.TrimStart("Option:")

    $retHash = @{}
    
    $rethash.Name = $Name
    $rethash.Value = $Value

    Write-DSCString -Resource -Name "AuditPolicyOption: $Name" -Type AuditPolicyOption -Parameters $rethash
}
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
    $GUID = $Entry.'Subcategory GUID'.TrimStart("{").TrimEnd("}")
    if (!$AuditSubcategoryHash.ContainsKey($GUID))
    {
        Write-Warning "Write-GPOAuditCSVData:$GUID ($($Entry.Subcategory)) is no longer supported or not implemented"
        Add-ProcessingHistory -Type AuditPolicySubcategory -Name "EventAuditing(GPO) $($Entry.SubCategory)" -ParsingError
        return ""
    }

    $retHash.Name = $AuditSubCategoryHash[$GUID]
    $Name = $Entry.SubCategory

    switch -regex ($Entry."Inclusion Setting")
    {
        "Success and Failure"
        {
            $retHash.Ensure = "Present"
            $retHash.AuditFlag = "Success"
            $duplicate = $retHash.Clone()
            $duplicate.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Success) - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
            Write-DSCString -Resource -Name "$Name (Failure) - Inclusion" -Type AuditPolicySubcategory -Parameters $duplicate
        }

        "No Auditing"
        {
            $retHash.Ensure = "Absent"
            $retHash.AuditFlag = "Success"
            $duplicate = $retHash.Clone()
            $duplicate.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Success) - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
            $retHash.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Failure) - Inclusion" -Type AuditPolicySubcategory -Parameters $duplicate
        }

        "^(Success|Failure)$"
        {
            $retHash.Ensure = "Present"
            $retHash.AuditFlag = $Entry."Inclusion Setting"
            Write-DSCString -Resource -Name "$Name - Inclusion" -Type AuditPolicySubcategory -Parameters $retHash
        }
    }
    
    $exclusionHash = $retHash.Clone()
    switch -regex ($Entry."Exclusion Setting")
    {
        "Success and Failure"
        {
            $exclusionHash.Ensure = "Absent"
            $exclusionHash.AuditFlag = "Success"
            $exclusionHashduplicate = $exclusionHash.Clone()
            $exclusionHashduplicate.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Success) - Exclusion" -Type AuditPolicySubcategory -Parameters $exclusionHash
            $retHash.AuditFlag = "Failure"
            Write-DSCString -Resource -Name "$Name (Failure) - Exclusion" -Type AuditPolicySubcategory -Parameters $exclusionHashduplicate
        }

        "No Auditing"
        {
            # I am not sure how to make sure that "No Auditing" is Excluded or ABSENT. What should it be set to then?
        }

        "^(Success|Failure)$"
        {
            $exclusionHash.Ensure = "Absent"
            $exclusionHash.AuditFlag = $Entry."Exclusion Setting"
            Write-DSCString -Resource -Name "$Name - Exclusion" -Type AuditPolicySubcategory -Parameters $exclusionHash
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
        Add-ProcessingHistory -Type AuditPolicySubcategory -Name "EventAuditing(INF) $($key)" -ParsingError
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
                Write-DSCString -Resource -Name "EventAuditing(INF): $($subCategory): NoAuditing(Failure)" -Type AuditPolicySubcategory -Parameters $paramHash 
                $paramHash.AuditFlag = "Success"
                $paramHash.Ensure = "Absent"
                Write-DSCString -Resource -Name "EventAuditing(INF): $($subCategory): NoAuditing(Success)" -Type AuditPolicySubcategory -Parameters $paramHash 
                return
            } 
            
            "(1|3)"
            {
                $paramHash.AuditFlag = "Success"
                Write-DSCString -Resource -Name "EventAuditing(INF): $($subCategory): Success" -Type AuditPolicySubcategory -Parameters $paramHash 
            }

            "(2|3)"
            {
                $paramHash.AuditFlag = "Failure"
                Write-DSCString -Resource -Name "EventAuditing(INF): $($subCategory): Failure" -Type AuditPolicySubcategory -Parameters $paramHash 
            }

            Default 
            {
                Write-Warning "Write-GPOAuditINFData: $_ is not supported"
                Add-ProcessingHistory -Type AuditPolicySubcategory -Name "EventAuditing(INF): $($key)" -ParsingError
            }
        }
    }
}
