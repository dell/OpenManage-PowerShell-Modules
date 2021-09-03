---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Remove-OMEGroup

## SYNOPSIS
Remove group from OpenManage Enterprise

## SYNTAX

```
Remove-OMEGroup [-Group] <Group> [<CommonParameters>]
```

## DESCRIPTION
Remove group from OpenManage Enterprise

## EXAMPLES

### EXAMPLE 1
```
Get-OMEGroup "Test Group 01" | Remove-OMEGroup
```

Remove group

## PARAMETERS

### -Group
Object of type Group returned from Get-OMEGroup function

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

### None
## OUTPUTS

## NOTES

## RELATED LINKS
