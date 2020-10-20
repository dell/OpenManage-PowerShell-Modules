Class Baseline {
    [Int]$Id
    [String]$Name
    [String]$Description
    [Int]$CatalogId
    [Int]$RepositoryId
    [String]$RepositoryName
    [String]$RepositoryType
    [nullable[DateTime]]$LastRun
    [Boolean]$DowngradeEnabled
    [Int[]]$Targets
}