---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Set-OMEChassisSlotName

## SYNOPSIS
Set Chassis slot names

## SYNTAX

```
Set-OMEChassisSlotName [-Chassis] <Device> [-Slot] <Int32> [-Name] <String> [[-SlotType] <String>] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Set-OMEChassisSlotName -Chassis $("C38V9ZZ" | Get-OMEDevice) -Slot 1 -Name "MX840c-C39N9ZZ" -Wait -Verbose
Set chassis sled slot name
```

### EXAMPLE 2
```
Set-OMEChassisSlotName -Chassis $("C38V9ZZ" | Get-OMEDevice) -Slot 4 -Name "MX5016s-C39R9ZZ" -SlotType "STORAGESLED" -Wait -Verbose
Set chassis storage sled slot name
```

### EXAMPLE 3
```
Set-OMEChassisSlotName -Chassis $("C38V9ZZ" | Get-OMEDevice) -Slot 1 -Name "MX5108-C38T9ZZ" -SlotType "IOM" -Wait -Verbose
Set chassis IOM slot name
```

## PARAMETERS

### -Chassis
Object of type Device returned from Get-OMEDevice function.
Must be a Chassis device type.

```yaml
Type: Device
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Slot
Int to represent the slot number

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
String to represent the slot name

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

### -SlotType
String to represent the slot type (Default="SLED", "STORAGESLED", "IOM")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: SLED
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

### Device
## OUTPUTS

## NOTES

## RELATED LINKS
