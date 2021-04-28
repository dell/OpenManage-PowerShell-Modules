using module .\DiscoveryTarget.psm1
using module .\Schedule.psm1

Class Discovery {
    [Int]$Id
    [String]$Name
    [String]$EmailRecipient
    [Boolean]$CreateGroup
    [Boolean]$TrapDestination
    [Boolean]$CommunityString
    [Boolean]$UseAllProfiles
    [PSCustomObject]$ConnectionProfile
    [Int[]]$DeviceType
    [DiscoveryTarget[]]$Hosts
    [Schedule]$Schedule
}