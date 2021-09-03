---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEFirmwareBaseline

## SYNOPSIS
Create new firmware baseline in OpenManage Enterprise

## SYNTAX

```
New-OMEFirmwareBaseline [-Name] <String> [[-Description] <String>] [-Catalog] <Catalog> [[-Group] <Group>]
 [[-Devices] <Device[]>] [-AllowDowngrade] [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
A baseline is used to compare updates in a catalog against a set of devices.

## EXAMPLES

### EXAMPLE 1
```
New-OMEFirmwareBaseline -Name "TSTestBaseline01" -Catalog $("Auto-Update-Online" | Get-OMECatalog) -Devices $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") | Format-Table
```

Create new firmware baseline using existing catalog

## PARAMETERS

### -Name
Name of baseline

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of baseline

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Catalog
Object of type Catalog returned from Get-OMECatalog function

```yaml
Type: Catalog
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Object of type Group returned from Get-OMEGroup function

```yaml
Type: Group
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Devices
Array of type Device returned from Get-OMEDevice function

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowDowngrade
Allow downgrade of component firmware

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
Position: 6
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
