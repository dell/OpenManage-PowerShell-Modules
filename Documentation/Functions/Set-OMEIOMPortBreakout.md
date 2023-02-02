---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Set-OMEIOMPortBreakout

## SYNOPSIS
Configure port breakout on IOM devices

## SYNTAX

```
Set-OMEIOMPortBreakout [[-Name] <String>] [-Device] <Device> [-BreakoutType] <String> [-PortGroups] <String>
 [-RefreshInventory] [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Only supports configuring 1 IOM device per execution but multiple port groups can be configured with the same BreakoutType.

## EXAMPLES

### EXAMPLE 1
```
Set-OMEIOMPortBreakout -Device $("C38S9T2" | Get-OMEDevice) -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait -Verbose
```

Configure port for 4 x 10GE breakout and wait for job to complete

### EXAMPLE 2
```
Set-OMEIOMPortBreakout -Device $("C38S9T2" | Get-OMEDevice) -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait -RefreshInventory -Verbose
```

Configure port for 4 x 10GE breakout, wait for job to complete and refresh device inventory upon completion.

### EXAMPLE 3
```
Set-OMEIOMPortBreakout -Device $("C38S9T2" | Get-OMEDevice) -BreakoutType "4X8GFC" -PortGroups "port-group1/1/15,port-group1/1/16" -Verbose
```

Configure multiple ports for 4 x 8G FC

## PARAMETERS

### -Name
Name of the configure port breakout job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Set Port Breakout $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Device
Object of type Device returned from Get-OMEDevice function.
Only supports configuring 1 device per execution.

```yaml
Type: Device
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BreakoutType
String specifing the breakout type.
("4X25GE","2X50GE","4X10GE","4X1GE","1X40GE","1X100GE","4X16GFC","4X32GFC","2X32GFC","4X8GFC","1X32GFC","HardwareDefault")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PortGroups
Comma delimited string specifing the port group(s) to configure.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshInventory
Refresh IOM device inventory upon job completion.
Required to update the OME-M UI with changes to port breakout.
Requires -Wait parameter to be specified.

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
Position: 5
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
