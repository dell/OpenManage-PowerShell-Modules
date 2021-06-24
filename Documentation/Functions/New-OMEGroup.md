---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEGroup

## SYNOPSIS
Create new static group in OpenManage Enterprise

## SYNTAX

```
New-OMEGroup [-Name] <String> [[-Description] <String>] [<CommonParameters>]
```

## DESCRIPTION
Only static groups are supported currently.
Raise an issue on Github for query group support.

## EXAMPLES

### EXAMPLE 1
```
New-OMEGroup -Name "Test Group 01"
Create a new static group
```

## PARAMETERS

### -Name
Name of group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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
