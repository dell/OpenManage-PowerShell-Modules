---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEApplicationSettings

## SYNOPSIS
Get Application Settings

## SYNTAX

```
Get-OMEApplicationSettings [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-OMEApplicationSettings
```

### EXAMPLE 2
```
Get-OMEApplicationSettings | Select-Object -ExpandProperty SystemConfiguration | Select-Object -ExpandProperty Components | Select-Object -First 1 | Select-Object -ExpandProperty Attributes | Format-Table
Display all Attributes in Table. See README for more examples.
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
