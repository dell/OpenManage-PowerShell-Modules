# Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

using module .\DiscoveredDevicesByType.psm1

Class DiscoveryJob {
    [Int]$JobId
    [String]$JobName
    [String]$JobDescription
    [String]$JobSchedule
    [nullable[DateTime]]$JobStartTime
    [nullable[DateTime]]$JobEndTime
    [String]$JobProgress
    [Int]$JobStatusId
    [nullable[DateTime]]$JobNextRun
    [Boolean]$JobEnabled
    [String]$UpdatedBy
    [nullable[DateTime]]$LastUpdateTime
    [Int]$DiscoveryConfigGroupId
    [Int]$DiscoveryConfigExpectedDeviceCount
    [Int]$DiscoveryConfigDiscoveredDeviceCount
    [String]$DiscoveryConfigEmailRecipient
	[DiscoveredDevicesByType[]]$DiscoveredDevicesByType
}