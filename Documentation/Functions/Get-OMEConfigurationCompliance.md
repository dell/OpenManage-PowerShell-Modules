---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEConfigurationCompliance

## SYNOPSIS
Get device configuration compliance report from OpenManage Enterprise

## SYNTAX

```
Get-OMEConfigurationCompliance [[-Baseline] <ConfigurationBaseline>] [[-DeviceFilter] <Device[]>]
 [<CommonParameters>]
```

## DESCRIPTION
To get the configuration compliance for a device you need to create a Configuration Baseline first.

## EXAMPLES

### EXAMPLE 1
```
"TestBaseline01" | Get-OMEConfigurationBaseline | Get-OMEConfigurationCompliance | Format-Table
```

Get configuration compliance report for all devices in baseline

### EXAMPLE 2
```
"TestBaseline01" | Get-OMEConfigurationBaseline | Get-OMEConfigurationCompliance -DeviceFilter $("FVKGSWZ" | Get-OMEDevice -FilterBy "ServiceTag") | Format-Table
```

Get configuration compliance report for specific devices in baseline

## PARAMETERS

### -Baseline
Array of type Baseline returned from Get-OMEConfigurationBaseline function

```yaml
Type: ConfigurationBaseline
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Baseline[]
## OUTPUTS

## NOTES

## RELATED LINKS
