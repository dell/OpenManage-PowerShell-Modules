---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Remove-OMECatalog

## SYNOPSIS
Remove firmware catalog from OpenManage Enterprise

## SYNTAX

```
Remove-OMECatalog [-Catalog] <Catalog> [<CommonParameters>]
```

## DESCRIPTION
Remove firmware catalog from OpenManage Enterprise

## EXAMPLES

### EXAMPLE 1
```
"AllLatest" | Get-OMEFirmwareBaseline | Remove-OMECatalog
```

Remove firmware baseline

## PARAMETERS

### -Catalog
Object of type Catalog returned from Get-OMEFirmwareBaseline

```yaml
Type: Catalog
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

### None
## OUTPUTS

## NOTES

## RELATED LINKS
