---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMESupportAssistGroup

## SYNOPSIS
Get groups from OpenManage Enterprise

## SYNTAX

```
Get-OMESupportAssistGroup [-Group] <Group> [<CommonParameters>]
```

## DESCRIPTION
Returns all groups if no input received

## EXAMPLES

### EXAMPLE 1
```
"Support Assist Group 1" | Get-OMEGroup | Get-OMESupportAssistGroup | Format-Table
```

Get group by name

### EXAMPLE 2
```
"Support Assist Group 1" | Get-OMEGroup | Get-OMESupportAssistGroup | ConvertTo-Json | Set-Content "C:\Temp\export.json"
```

Get group by name to file

## PARAMETERS

### -Group
{{ Fill Group Description }}

```yaml
Type: Group
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

### String[]
## OUTPUTS

## NOTES

## RELATED LINKS
