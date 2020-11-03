---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEDeviceNetworkDetail

## SYNOPSIS
Get device inventory from OpenManage Enterprise

## SYNTAX

```
Get-OMEDeviceNetworkDetail [-Devices] <Device[]> [<CommonParameters>]
```

## DESCRIPTION
Returns device inventory.
Can be filtered by InventoryType. 
Requires a Device object to be passed in from Get-OMEDevice

## EXAMPLES

### EXAMPLE 1
```
"C86F000", "3XMHHHH" | Get-OMEDevice -FilterBy "ServiceTag" | Get-OMEDeviceNetworkDetail
```

Get network device detail

## PARAMETERS

### -Devices
{{ Fill Devices Description }}

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Device[]
## OUTPUTS

## NOTES

## RELATED LINKS
