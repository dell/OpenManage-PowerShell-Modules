using module ..\Classes\Discovery.psm1
using module ..\Classes\DiscoveryTarget.psm1
using module ..\Classes\Schedule.psm1
function New-DiscoveryFromJson {
    Param(
        [PSCustomObject]$Discovery
    )

    $targets = @()
    foreach ($target in $Discovery.DiscoveryConfigModels[0].DiscoveryConfigTargets) {
        $targets += [DiscoveryTarget]@{
            Id = $target.DiscoveryConfigTargetId
            NetworkAddress = $target.NetworkAddressDetail
            SubnetMask = $target.SubnetMask
            AddressType = $target.AddressType
            Disabled = $target.Disabled
            Exclude = $target.Exclude
        }
    }

    $schedule = [Schedule]@{
        StartTime = $Discovery.Schedule.StartTime
        EndTime = $Discovery.Schedule.EndTime
        Cron = $Discovery.Schedule.Cron
    }

    return [Discovery]@{
        Id = $Discovery.DiscoveryConfigGroupId
        Name = $Discovery.DiscoveryConfigGroupName
        EmailRecipient = $Discovery.DiscoveryStatusEmailRecipient
        ConnectionProfile = $Discovery.DiscoveryConfigModels[0].ConnectionProfile
        DeviceType = $Discovery.DiscoveryConfigModels[0].DeviceType
        CreateGroup = $Discovery.CreateGroup
        TrapDestination = $Discovery.TrapDestination
        CommunityString = $Discovery.CommunityString
        UseAllProfiles = $Discovery.UseAllProfiles
        Hosts = $targets
        Schedule = $schedule
    }
}