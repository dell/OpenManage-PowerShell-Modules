---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Set-OMETemplateIdentityPool

## SYNOPSIS
Set Identity Pool on a Template

## SYNTAX

```
Set-OMETemplateIdentityPool [-Template] <Template[]> [-IdentityPool] <IdentityPool> [<CommonParameters>]
```

## DESCRIPTION
Set Identity Pool on a Template

## EXAMPLES

### EXAMPLE 1
```
"MX740c Template" | Get-OMETemplate | Set-OMETemplateIdentityPool -IdentityPool $("default" | Get-OMEIdentityPool) -Verbose
```

Set Identity Pool on Template

## PARAMETERS

### -Template
Object of type Template returned from Get-OMETemplate

```yaml
Type: Template[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IdentityPool
{{ Fill IdentityPool Description }}

```yaml
Type: IdentityPool
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Template
## OUTPUTS

## NOTES

## RELATED LINKS
