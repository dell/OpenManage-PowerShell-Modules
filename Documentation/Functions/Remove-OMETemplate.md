---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Remove-OMETemplate

## SYNOPSIS
Remove template in OpenManage Enterprise

## SYNTAX

```
Remove-OMETemplate [-Template] <Template> [<CommonParameters>]
```

## DESCRIPTION
Remove a configuration or deployment template from OpenManage Enterprise

## EXAMPLES

### EXAMPLE 1
```
Get-OMETemplate "TestTemplate01" | Remove-OMETemplate
```

## PARAMETERS

### -Template
Object of type Template returned from Get-OMETemplate function

```yaml
Type: Template
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

### [Template]Template
## OUTPUTS

## NOTES

## RELATED LINKS
