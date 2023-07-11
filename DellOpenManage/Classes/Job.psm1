using module .\JobDetail.psm1

Class Job {
    [Int]$Id
    [String]$JobName
    [String]$JobDescription
    [nullable[DateTime]]$NextRun
    [nullable[DateTime]]$LastRun
    [nullable[DateTime]]$StartTime
    [nullable[DateTime]]$EndTime
    [String]$Schedule
    [String]$State
    [String]$CreatedBy
    [String]$UpdatedBy
    [Boolean]$Visible
    [Boolean]$Editable
    [Boolean]$Builtin
    [Boolean]$UserGenerated
    [Int]$LastRunStatusId
    [String]$LastRunStatus
    [Int]$JobTypeId
    [String]$JobType
    [PSCustomObject[]]$Targets
    [JobDetail[]]$JobDetail
}