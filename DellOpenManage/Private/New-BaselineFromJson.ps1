using module ..\Classes\Baseline.psm1
function New-BaselineFromJson {
    Param(
        [PSCustomObject]$Baseline
    )
    $Targets = @()
    foreach ($Target in $Baseline.Targets){
        $Targets += $Target.Id
    }
    return [Baseline]@{
        Id = $Baseline.Id
        Name = $Baseline.Name
        Description = $Baseline.Description
        CatalogId = $Baseline.CatalogId
        RepositoryId = $Baseline.RepositoryId
        RepositoryName = $Baseline.RepositoryName
        RepositoryType = $Baseline.RepositoryType
        LastRun = $Baseline.LastRun
        DowngradeEnabled = $Baseline.DowngradeEnabled
        Targets = $Targets
    }
}