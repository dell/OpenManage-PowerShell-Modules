---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Update-OMEConfiguration

## SYNOPSIS
Update configuration on devices in OpenManage Enterprise

## SYNTAX

```
Update-OMEConfiguration [[-Name] <String>] [[-DeviceFilter] <Device[]>] [-Baseline] <ConfigurationBaseline>
 [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This will use an existing configuration baseline to submit a Job that updates configuration on a set of devices immediately.
***This will force a reboot if necessary***

## EXAMPLES

### EXAMPLE 1
```
Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -Wait -Verbose
```

Update configuration compliance on all devices in baseline ***This will force a reboot if necessary***

### EXAMPLE 2
```
Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait -Verbose
```

Update configuration compliance on filtered devices in baseline ***This will force a reboot if necessary***

## PARAMETERS

### -Name
Name of the configuration update job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Make Devices Compliant $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceFilter
Array of type Device returned from Get-OMEDevice function.
Used to limit the devices updated within the baseline.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Baseline
Array of type ConfigurationBaseline returned from Get-OMEConfigurationBaseline function

```yaml
Type: ConfigurationBaseline
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
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
Position: 4
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
