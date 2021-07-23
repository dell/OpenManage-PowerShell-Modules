Class IdentityPool {
    [Int]$Id
    [String]$Name
    [String]$Description
    [String]$CreatedBy
    [nullable[DateTime]]$CreationTime
    [String]$LastUpdatedBy
    [nullable[DateTime]]$LastUpdateTime
    [PSCustomObject]$EthernetSettings
    [PSCustomObject]$IscsiSettings
    [PSCustomObject]$FcoeSettings
    [PSCustomObject]$FcSettings
}