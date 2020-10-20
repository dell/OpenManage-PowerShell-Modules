Class JobDetail {
    [Int]$Id
    [String]$Key
    [String]$StatusId
    [String]$Status
    [String]$Progress
    [String]$ElapsedTime
    [nullable[DateTime]]$StartTime
    [nullable[DateTime]]$EndTime
    [String]$Output
}