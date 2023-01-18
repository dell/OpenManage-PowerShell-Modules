using module ..\Classes\ApplianceInfo.psm1
function New-ApplianceInfoFromJson {
    Param(
        [PSCustomObject]$ApplianceInfo
    )
    $ApplianceInfoObj = [ApplianceInfo]@{
        Name = $ApplianceInfo.Name
        Description = $ApplianceInfo.Description
        Vendor = $ApplianceInfo.Vendor
        Branding = $ApplianceInfo.Branding
        Version = [Version]$ApplianceInfo.Version
        BuildNumber = $ApplianceInfo.BuildNumber
        BuildDate = $ApplianceInfo.BuildDate
        Guid = $ApplianceInfo.Guid
        OperationStatus = $ApplianceInfo.OperationStatus
    }
    return $ApplianceInfoObj
}

