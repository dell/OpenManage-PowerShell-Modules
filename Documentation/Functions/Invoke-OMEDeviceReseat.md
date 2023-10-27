---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEDeviceReseat

## SYNOPSIS
Virtual reseat device in OpenManage Enterprise

## SYNTAX

```
Invoke-OMEDeviceReseat [[-Name] <String>] [[-Devices] <Device[]>] [-Wait] [[-WaitTime] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
This will submit a job to do a virtual reseat on a Compute device in an MX Chassis

## EXAMPLES

### EXAMPLE 1
```
"933NCZZ" | Get-OMEDevice | Invoke-OMEDeviceReseat -Verbose -Wait
```

Trigger virtual system reseat

## PARAMETERS

### -Name
Name of the job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Virtual Reseat $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Devices
Array of type Device returned from Get-OMEDevice function.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Wait
{{ Fill Wait Description }}

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
{{ Fill WaitTime Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
