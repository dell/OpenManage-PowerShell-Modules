---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEFirmwareCompliance

## SYNOPSIS
Get device firmware compliance report from OpenManage Enterprise

## SYNTAX

```
Get-OMEFirmwareCompliance [[-Baseline] <Baseline[]>] [[-DeviceFilter] <Device[]>] [[-ComponentFilter] <String>]
 [[-UpdateAction] <String[]>] [[-Output] <String>] [<CommonParameters>]
```

## DESCRIPTION
To get the list of firmware updates for a device you need a Catalog and a Baseline first. 
Then you can see the firmware that needs updated.

## EXAMPLES

### EXAMPLE 1
```
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance | Format-Table
```

Get report for existing baseline

### EXAMPLE 2
```
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -DeviceFilter $("FVKGSWZ" | Get-OMEDevice -FilterBy "ServiceTag") | Format-Table
```

Filter report by device in baseline

### EXAMPLE 3
```
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -ComponentFilter "iDRAC" | Format-Table
```

Filter report by component in baseline

## PARAMETERS

### -Baseline
Array of type Baseline returned from Get-Baseline function

```yaml
Type: Baseline[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DeviceFilter
Array of type Device returned from Get-OMEDevice function.
Used to limit the devices updated within the baseline.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComponentFilter
String to represent component name.
Used to limit the components updated within the baseline.
Supports regex via Powershell -match

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

### -UpdateAction
Determines what type of updates will be performed.
(Default="Upgrade", "Downgrade", "All")

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Upgrade
Accept pipeline input: False
Accept wildcard characters: False
```

### -Output
{{ Fill Output Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Report
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Baseline[]
## OUTPUTS

## NOTES

## RELATED LINKS
