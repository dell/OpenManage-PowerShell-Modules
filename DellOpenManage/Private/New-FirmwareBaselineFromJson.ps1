using module ..\Classes\FirmwareBaseline.psm1
function New-FirmwareBaselineFromJson {
    Param(
        [PSCustomObject]$FirmwareBaseline
    )
    $Targets = @()
    foreach ($Target in $FirmwareBaseline.Targets){
        $Targets += $Target.Id
    }
    return [FirmwareBaseline]@{
        Id = $FirmwareBaseline.Id
        Name = $FirmwareBaseline.Name
        Description = $FirmwareBaseline.Description
        CatalogId = $FirmwareBaseline.CatalogId
        RepositoryId = $FirmwareBaseline.RepositoryId
        RepositoryName = $FirmwareBaseline.RepositoryName
        RepositoryType = $FirmwareBaseline.RepositoryType
        LastRun = $FirmwareBaseline.LastRun
        DowngradeEnabled = $FirmwareBaseline.DowngradeEnabled
        Targets = $Targets
    }
}