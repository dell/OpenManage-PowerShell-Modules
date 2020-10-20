using module .\Repository.psm1
using module .\Schedule.psm1

Class Catalog {
    [Int]$Id
    [String]$Filename
    [String]$SourcePath
    [String]$Status
    [String]$BaseLocation
    [String]$ManifestVersion
    [nullable[DateTime]]$ReleaseDate
    [nullable[DateTime]]$LastUpdated
    [nullable[DateTime]]$NextUpdate
    [Schedule]$Schedule
    [Repository]$Repository
    #AssociatedBaselines
}