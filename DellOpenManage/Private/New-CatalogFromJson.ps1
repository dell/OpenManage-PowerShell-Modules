using module ..\Classes\Catalog.psm1
using module ..\Classes\Schedule.psm1
using module ..\Classes\Repository.psm1
function New-CatalogFromJson {
    Param(
        [PSCustomObject]$Catalog
    )
    $repo = [Repository]@{
        Id = $Catalog.Repository.Id
        Name = $Catalog.Repository.Name
        Description = $Catalog.Repository.Description
        Source = $Catalog.Repository.Source
        DomainName = $Catalog.Repository.DomainName
        Username = $Catalog.Repository.Username
        Password = $Catalog.Repository.Password
        CheckCertificate = $Catalog.Repository.CheckCertificate
        RepositoryType = $Catalog.Repository.RepositoryType
    }
    
    $schedule = [Schedule]@{
        StartTime = $Catalog.Schedule.StartTime
        EndTime = $Catalog.Schedule.EndTime
        Cron = $Catalog.Schedule.Cron
    }

    return [Catalog]@{
        Id = $Catalog.Id
        Filename = $Catalog.Filename
        SourcePath = $Catalog.SourcePath
        Status = $Catalog.Status
        BaseLocation = $Catalog.BaseLocation
        ManifestVersion = $Catalog.ManifestVersion
        ReleaseDate = $Catalog.ReleaseDate
        LastUpdated = $Catalog.LastUpdated
        NextUpdate = $Catalog.NextUpdate
        Schedule = $schedule
        Repository = $repo
    }
}