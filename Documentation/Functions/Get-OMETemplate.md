---
author: Trevor Squillario
category: DELLOPENMANAGE
external help file: DellOpenManage-help.xml
layout: post
Module Name: DellOpenManage
online version:
schema: 2.0.0
tags: OnlineHelp PowerShell
title: Get-OMETemplate
---

# Get-OMETemplate

## SYNOPSIS
Get template from OpenManage Enterprise

## SYNTAX

```
Get-OMETemplate [[-Value] <String[]>] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns all templates if no input received

## EXAMPLES

### EXAMPLE 1
```
Get-OMETemplate | Format-Table
```

Get all templates

### EXAMPLE 2
```
"DRM" | Get-OMETemplate | Format-Table
```

Get template by name

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
Filter the results by (Default="Name", "Id")

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
