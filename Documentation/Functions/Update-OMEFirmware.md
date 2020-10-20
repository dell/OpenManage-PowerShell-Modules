---
author: Trevor Squillario
category: DELLOPENMANAGE
external help file: DellOpenManage-help.xml
layout: post
Module Name: DellOpenManage
online version:
schema: 2.0.0
tags: OnlineHelp PowerShell
title: Update-OMEFirmware
---

# Update-OMEFirmware

## SYNOPSIS
Update firmware on devices in OpenManage Enterprise

## SYNTAX

```
Update-OMEFirmware [[-DeviceFilter] <Device[]>] [[-ComponentFilter] <String>] [-Baseline] <Baseline>
 [[-UpdateSchedule] <String>] [[-UpdateAction] <String[]>] [-ResetiDRAC] [-ClearJobQueue] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This will use an existing firmware baseline to submit a Job that updates firmware on a set of devices.

## EXAMPLES

### EXAMPLE 1
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) | Format-Table
```

Display device compliance report for all devices in baseline.
No updates are installed by default.

### EXAMPLE 2
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "RebootNow"
```

Update firmware on all devices in baseline immediately ***Warning: This will force a reboot of all servers

### EXAMPLE 3
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot"
```

Update firmware on all devices in baseline on next reboot

### EXAMPLE 4
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow"
```

Update firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers

### EXAMPLE 5
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -ComponentFilter "iDRAC" -UpdateSchedule "StageForNextReboot" -ClearJobQueue
```

Update firmware on specific components in baseline on next reboot and clear job queue before update

## PARAMETERS

### -DeviceFilter
Array of type Device returned from Get-OMEDevice function.
Used to limit the devices updated within the baseline.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComponentFilter
String to represent component name.
Used to limit the components updated within the baseline.
Supports regex via Powershell -match

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Baseline
Array of type Baseline returned from Get-Baseline function

```yaml
Type: Baseline
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateSchedule
Determines when the updates will be performed.
(Default="Preview", "RebootNow", "StageForNextReboot")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Preview
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateAction
Determines what type of updates will be performed.
(Default="Upgrade", "Downgrade", "All")

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Upgrade
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResetiDRAC
This option will restart the iDRAC.
Occurs immediately, regardless if StageForNextReboot is set

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClearJobQueue
This option clears any active or pending jobs.
Occurs immediately, regardless if StageForNextReboot is set

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
Wait for job to complete

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WaitTime
Time, in seconds, to wait for the job to complete

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

## NOTES

## RELATED LINKS
