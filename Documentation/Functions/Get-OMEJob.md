---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEJob

## SYNOPSIS
Get job from OpenManage Enterprise

## SYNTAX

```
Get-OMEJob [[-Value] <String[]>] [-Detail] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-OMEJOb | Format-Table
```

List all jobs

### EXAMPLE 2
```
13852 | Get-OMEJob -Detail -Verbose
```

Get job by Id

### EXAMPLE 3
```
5 | Get-OMEJob -FilterBy "Type" | Format-Table
```

Get job by job type

### EXAMPLE 4
```
2060 | Get-OMEJob -FilterBy "LastRunStatus" | Format-Table
```

Get job by last run status

### EXAMPLE 5
```
"Enabled" | Get-OMEJob -FilterBy "State" | Format-Table
```

Get job by state

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

### -Detail
Show detailed job info such as progress, elapsed time or output

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

### -FilterBy
Filter the results by (Default="Id", "Status", "LastRunStatus", "Type", "State")

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
