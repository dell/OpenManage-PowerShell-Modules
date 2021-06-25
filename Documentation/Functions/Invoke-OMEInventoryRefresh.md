---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEInventoryRefresh

## SYNOPSIS
Refresh inventory on devices in OpenManage Enterprise

## SYNTAX

```
Invoke-OMEInventoryRefresh [[-Name] <String>] [[-Devices] <Device[]>] [-Wait] [[-WaitTime] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
This will submit a job to refresh the inventory on provided Devices.

## EXAMPLES

### EXAMPLE 1
```
"PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Invoke-OMEInventoryRefresh -Verbose
Create separate inventory refresh job for each device in list
```

### EXAMPLE 2
```
,$("PowerEdge R640" | Get-OMEDevice -FilterBy "Model") | Invoke-OMEInventoryRefresh -Verbose
Create one inventory refresh job for all devices in list. Notice the preceeding comma before the device list.
```

## PARAMETERS

### -Name
Name of the inventory refresh job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Inventory Task Device $((Get-Date).ToString('yyyyMMddHHmmss'))"
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
