---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEGroup

## SYNOPSIS
Get groups from OpenManage Enterprise

## SYNTAX

```
Get-OMEGroup [[-Value] <String[]>] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns all groups if no input received

## EXAMPLES

### EXAMPLE 1
```
Get-OMEGroup | Format-Table
```

Get all groups

### EXAMPLE 2
```
"Servers_Win" | Get-OMEGroup | Format-Table
```

Get group by name

### EXAMPLE 3
```
"Servers_ESXi", "Servers_Win" | Get-OMEGroup | Format-Table
```

Get multiple groups

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
Filter the results by ("Name", "Id")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Name
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
