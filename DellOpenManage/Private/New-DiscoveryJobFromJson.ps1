# Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

using module ..\Classes\DiscoveryJob.psm1
using module ..\Classes\DiscoveredDevicesByType.psm1

function New-DiscoveryJobFromJson {
    Param(
        [PSCustomObject]$DiscoveryJob
    )

    $DevicesByType = @()
    foreach ($target in $DiscoveryJob.DiscoveredDevicesByType) {
        $DevicesByType += [DiscoveredDevicesByType]@{
            DeviceType = $target.DeviceType
            Count = $target.Count
        }
    }

    return [DiscoveryJob]@{
        JobId = $DiscoveryJob.JobId
        JobName = $DiscoveryJob.JobName
        JobDescription = $DiscoveryJob.JobDescription
        JobSchedule = $DiscoveryJob.JobSchedule
        JobStartTime = $DiscoveryJob.JobStartTime
        JobEndTime = $DiscoveryJob.JobEndTime
        JobProgress = $DiscoveryJob.JobProgress
        JobStatusId = $DiscoveryJob.JobStatusId
        JobNextRun = $DiscoveryJob.JobNextRun
        JobEnabled = $DiscoveryJob.JobEnabled
        UpdatedBy = $DiscoveryJob.UpdatedBy
        LastUpdateTime = $DiscoveryJob.LastUpdateTime
        DiscoveryConfigGroupId = $DiscoveryJob.DiscoveryConfigGroupId
        DiscoveryConfigExpectedDeviceCount = $DiscoveryJob.DiscoveryConfigExpectedDeviceCount
        DiscoveryConfigDiscoveredDeviceCount = $DiscoveryJob.DiscoveryConfigDiscoveredDeviceCount
        DiscoveryConfigEmailRecipient = $DiscoveryJob.DiscoveryConfigEmailRecipient
        DiscoveredDevicesByType = $DevicesByType
    }

}