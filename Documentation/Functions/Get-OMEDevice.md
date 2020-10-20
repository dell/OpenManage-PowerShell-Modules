---
author: Trevor Squillario
category: DELLOPENMANAGE
external help file: DellOpenManage-help.xml
layout: post
Module Name: DellOpenManage
online version:
schema: 2.0.0
tags: OnlineHelp PowerShell
title: Get-OMEDevice
---

# Get-OMEDevice

## SYNOPSIS
Get devices managed by OpenManage Enterprise

## SYNTAX

```
Get-OMEDevice [[-Value] <String[]>] [[-Group] <Group[]>] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get devices and filter by Id or ServiceTag.
Returns all devices if no input received.

## EXAMPLES

### EXAMPLE 1
```
Get-OMEDevice -Value 12016
```

Get device by Id

### EXAMPLE 2
```
"FVKGSWZ" | Get-OMEDevice -FilterBy "ServiceTag" | Format-Table
```

Get device by Service Tag

### EXAMPLE 3
```
10097, 10100 | Get-OMEDevice -FilterBy "Id" | Format-Table
```

Get multiple devices by Id

### EXAMPLE 4
```
"C86F0Q2", "3XMHHL2" | Get-OMEDevice | Format-Table
```

Get multiple devices by Service Tag

### EXAMPLE 5
```
"R620-FVKGSW2.example.com" | Get-OMEDevice -FilterBy "Name" | Format-Table
```

Get device by name

### EXAMPLE 6
```
"PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Format-Table
```

Get device by model

### EXAMPLE 7
```
"Servers_Win" | Get-OMEGroup | Get-OMEDevice | Format-Table
```

Get devices by group

### EXAMPLE 8
```
Get-OMEDevice -Group $(Get-OMEGroup "Servers_Win") | Format-Table
```

Get devices by group inline

### EXAMPLE 9
```
"Servers_ESXi", "Servers_Win" | Get-OMEGroup | Get-OMEDevice | Format-Table
```

Get devices from multiple groups

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

### -Group
Array of type Group returned from Get-OMEGroup function

```yaml
Type: Group[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilterBy
Filter the results by (Default="ServiceTag", "Name", "Id", "Model", "Type")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: ServiceTag
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Group[]
### String[]
## OUTPUTS

## NOTES

## RELATED LINKS
