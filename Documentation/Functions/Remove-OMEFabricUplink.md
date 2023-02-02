---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Remove-OMEFabricUplink

## SYNOPSIS
Remove uplink

## SYNTAX

```
Remove-OMEFabricUplink [-Fabric] <Fabric> [-Uplink] <Uplink> [<CommonParameters>]
```

## DESCRIPTION
Remove uplink

## EXAMPLES

### EXAMPLE 1
```
Remove-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric) -Uplink $("EthernetUplink01" | Get-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric))
```

Remove uplink

## PARAMETERS

### -Fabric
Object of type Fabric returned from Get-OMEFabric

```yaml
Type: Fabric
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uplink
Object of type Uplink returned from Get-OMEFabricUplink

```yaml
Type: Uplink
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Uplink
## OUTPUTS

## NOTES

## RELATED LINKS
