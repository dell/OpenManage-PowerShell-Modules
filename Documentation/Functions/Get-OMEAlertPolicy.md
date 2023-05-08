---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEAlertPolicy

## SYNOPSIS
Get alert policy

## SYNTAX

```
Get-OMEAlertPolicy [[-Value] <String[]>] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
12016 | Get-OMEAlertPolicy
```

Get by Id

### EXAMPLE 2
```
Get-OMEAlertPolicy | Where-Object { $_.Name -eq "Group A Alert" }
```

Get by Name (OME API does not currently support filtering by Name natively)

## PARAMETERS

### -Value
String containing search value.
Use with -FilterBy parameter

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilterBy
Filter the results by (Default="Id")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Id
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String[]
## OUTPUTS

## NOTES

## RELATED LINKS
