---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEInventoryRefresh

## SYNOPSIS
Refresh inventory on devices in OpenManage Enterprise

## SYNTAX

```
Invoke-OMEInventoryRefresh [[-Name] <String>] [[-Devices] <Device[]>] [<CommonParameters>]
```

## DESCRIPTION
This will submit a job to refresh the inventory on provided Devices.

## EXAMPLES

### EXAMPLE 1
```
Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -Wait -Verbose
Update configuration compliance on all devices in baseline ***This will force a reboot if necessary***
```

### EXAMPLE 2
```
Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait -Verbose
Update configuration compliance on filtered devices in baseline ***This will force a reboot if necessary***
```

## PARAMETERS

### -Name
Name of the inventory refresh job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Inventory Task Device $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Devices
Array of type Device returned from Get-OMEDevice function.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Device
## OUTPUTS

## NOTES

## RELATED LINKS
