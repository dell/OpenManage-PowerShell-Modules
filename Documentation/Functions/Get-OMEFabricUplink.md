---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEFabricUplink

## SYNOPSIS
Get list of fabric uplinks

## SYNTAX

```
Get-OMEFabricUplink [[-Name] <String>] [-Fabric] <Fabric> [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API.
Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
"Uplink01" | Get-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric)
```

Get uplink by name

### EXAMPLE 2
```
Get-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric) | Format-Table
```

Get all uplinks

## PARAMETERS

### -Name
String containing fabric name to search

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Fabric
{{ Fill Fabric Description }}

```yaml
Type: Fabric
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
