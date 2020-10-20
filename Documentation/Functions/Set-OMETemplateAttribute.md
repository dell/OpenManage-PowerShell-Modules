---
author: Trevor Squillario
category: DELL.OPENMANAGEENTERPRISE
external help file: DellOpenManage-help.xml
layout: post
Module Name: DellOpenManage
online version:
schema: 2.0.0
tags: OnlineHelp PowerShell
title: Set-OMETemplateAttribute
---

# Set-OMETemplateAttribute

## SYNOPSIS
Get firmware/driver catalog from OpenManage Enterprise

## SYNTAX

```
Set-OMETemplateAttribute [[-Id] <String[]>] [[-Attributes] <TemplateAttribute[]>] [<CommonParameters>]
```

## DESCRIPTION
Returns all catalogs if no input received

## EXAMPLES

### EXAMPLE 1
```
Get-OMETemplate | Format-Table
```

Get all catalogs

### EXAMPLE 2
```
"DRM" | Get-OMETemplate | Format-Table
```

Get catalog by name

## PARAMETERS

### -Id
String containing Id or Name of catalog

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

### -Attributes
{{ Fill Attributes Description }}

```yaml
Type: TemplateAttribute[]
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

### String[]
## OUTPUTS

## NOTES

## RELATED LINKS
