#region GPO Parsers
Function Write-GPOInternetSettingsXMLData
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$XML
    )

    # DSC does not allow for Internet Explorer version filtering, so we have to comment all of these out.
    $CommentOut = $false

    $regHash = @{}
    $Name = "InternetSettings(XML): $($XML.Id) ($($($XML.ParentNode.ParentNode.Name)))"
    $Min = $XML.ParentNode.ParentNode.Filter.FilerFile.Min
    $Max = $XML.ParentNode.ParentNode.Filter.FilerFile.Max

    if ($Min -ne $null -and $Max -ne $null)
    {
        $Condition = {$InternetExplorerVersion -gt $Min -and $InternetExplorerVersion -lt $Max}
    }
    else
    {
        $Condition = $executionContext.invokeCommand.NewScriptBlock("$InternetExplorerVersion -eq '$($XML.ParentNode.ParentNode.Name)'")
    }

    $regHash.ValueName = $XML.name
    switch ($XML.hive)
    {
        "HKEY_LOCAL_MACHINE" { $regHash.Key = Join-Path -Path "HKLM:" -ChildPath $XML.Key}
        "HKEY_CURRENT_USER"
        {
            $regHash.Key = Join-Path -Path "HKCU:" -ChildPath $XML.Key
            Write-Verbose "Write-GPOInternetSettingsXMLData: CurrentUser settings are not currently supported"
            $CommentOut = $true
        }
    }

    if ($XML.defaultValue)
    {
        Write-Verbose "Write-GPOInternetSettingsXMLData: Registry Default Values and User BitField masks are not yet supported"
        $CommentOUT = $true
    }

    $regHash.ValueData = $ValueData
    $regHash.ValueType = $XML.type

    Update-RegistryHashtable -Hashtable $regHash
    Write-DSCString -Resource -Type Registry -Name $Name -CommentOut:$CommentOut -Parameters $regHash -Condition $Condition
}
#endregion
