---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Remove-OMEFirmwareBaseline

## SYNOPSIS
Remove firmware baseline from OpenManage Enterprise

## SYNTAX

```
Remove-OMEFirmwareBaseline [-FirmwareBaseline] <FirmwareBaseline> [<CommonParameters>]
```

## DESCRIPTION
Remove firmware baseline from OpenManage Enterprise

## EXAMPLES

### EXAMPLE 1
```
"AllLatest" | Get-OMEFirmwareBaseline | Remove-OMEFirmwareBaseline
```

Remove firmware baseline

## PARAMETERS

### -FirmwareBaseline
Object of type FirmwareBaseline returned from Get-OMEFirmwareBaseline

```yaml
Type: FirmwareBaseline
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
