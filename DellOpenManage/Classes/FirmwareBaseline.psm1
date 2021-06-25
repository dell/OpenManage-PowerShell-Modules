Class FirmwareBaseline {
    [Int]$Id
    [String]$Name
    [String]$Description
    [Int]$TaskId
    [Int]$TaskStatusId
    [Int]$CatalogId
    [Int]$RepositoryId
    [String]$RepositoryName
    [String]$RepositoryType
    [nullable[DateTime]]$LastRun
    [Boolean]$DowngradeEnabled
    [Int[]]$Targets
}