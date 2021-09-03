---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Update-OMEFirmwareDUP

## SYNOPSIS
Update firmware via DUP (EXE) on devices in OpenManage Enterprise

## SYNTAX

```
Update-OMEFirmwareDUP [[-Name] <String>] [-DupFile] <FileInfo> [[-Group] <Group>] [[-Device] <Device>]
 [[-UpdateSchedule] <String>] [[-UpdateScheduleCron] <String>] [-ResetiDRAC] [-ClearJobQueue] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This will upload a DUP (EXE) file and submit a Job that updates firmware on a set of devices.
If you encounter the error "An existing connection was forcibly closed by the remote host" close and reopen the PowerShell console.
Not sure what is causing this.

## EXAMPLES

### EXAMPLE 1
```
"C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "Preview" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
```

Display device compliance report for device.
No updates are installed by default.

### EXAMPLE 2
```
"C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "RebootNow" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE" -Wait
```

Update firmware immediately and wait to job to complete ***Warning: This will force a reboot of all servers

### EXAMPLE 3
```
"C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "StageForNextReboot" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
```

Update firmware on next reboot

### EXAMPLE 4
```
"C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "ScheduleLater" -UpdateScheduleCron "0 0 0 1 11 ?" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
```

Update firmware on 11/1/2020 12:00AM UTC

### EXAMPLE 5
```
"C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "StageForNextReboot" -ClearJobQueue -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
```

Update firmware on next reboot and clear job queue before update

### EXAMPLE 6
```
"TestGroup" | Get-OMEGroup | Update-OMEFirmwareDUP -UpdateSchedule "RebootNow" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
```

Update firmware on all devices in group immediately ***Warning: This will force a reboot of all servers

## PARAMETERS

### -Name
Name of the firmware update job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Update Firmware With DUP $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -DupFile
{{ Fill DupFile Description }}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Array of type Group returned from Get-OMEGroup function.
Used to determine what groups to update.

```yaml
Type: Group
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Device
Array of type Device returned from Get-OMEDevice function.
Used to determine what devices to update.

```yaml
Type: Device
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UpdateSchedule
Determines when the updates will be performed.
(Default="Preview", "RebootNow", "ScheduleLater", "StageForNextReboot")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Preview
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateScheduleCron
Cron string to schedule updates at a later time.
Uses UTC time.
Used with -UpdateSchedule "ScheduleLater"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
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
Position: 7
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
