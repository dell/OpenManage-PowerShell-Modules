---
author: Trevor Squillario
category: DELLOPENMANAGE
external help file: DellOpenManage-help.xml
layout: post
Module Name: DellOpenManage
online version:
schema: 2.0.0
tags: OnlineHelp PowerShell
title: New-OMETemplateFromDevice
---

# New-OMETemplateFromDevice

## SYNOPSIS
Create template from source device in OpenManage Enterprise

## SYNTAX

```
New-OMETemplateFromDevice [-Device] <Device> [[-Name] <String>] [[-Description] <String>]
 [[-Component] <String[]>] [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
New-OMETemplateFromDevice -Component "iDRAC", "BIOS" -Device $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait
```

## PARAMETERS

### -Device
Single Device object returned from Get-OMEDevice function

```yaml
Type: Device
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
String that will be assigned the name of the template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "Template_$((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
String that will be assigned the description of the template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Component
Components to include in the template (Default="All", "iDRAC", "BIOS", "System", "NIC", "LifecycleController", "RAID", "EventFilters")

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: @("All")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
Wait for job to complete

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

### -WaitTime
Time, in seconds, to wait for the job to complete

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

## NOTES

## RELATED LINKS
