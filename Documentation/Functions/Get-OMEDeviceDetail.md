---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEDeviceDetail

## SYNOPSIS
Get device inventory from OpenManage Enterprise

## SYNTAX

```
Get-OMEDeviceDetail [-Devices] <Device[]> [[-InventoryType] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns device inventory.
Can be filtered by InventoryType. 
Requires a Device object to be passed in from Get-OMEDevice

## EXAMPLES

### EXAMPLE 1
```
"C86F000", "3XMHHHH" | Get-OMEDevice -FilterBy "ServiceTag" | Get-OMEDeviceDetail
```

Get all inventory for devices

### EXAMPLE 2
```
"C86F000", "3XMHHHH" | Get-OMEDevice -FilterBy "ServiceTag" | Get-OMEDeviceDetail -InventoryType "deviceSoftware"
```

Get software inventory for devices

## PARAMETERS

### -Devices
Array of type Device returned from Get-OMEDevice function.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -InventoryType
String to specify the inventory section to return (deviceCapabilities,serverDeviceCards,chassisControllerList,chassisFansList,chassisPciDeviceList,chassisPowerSupplies,chassisSlotsList,chassisStorageComputeAssociations,chassisTemperatureList,serverRaidControllers,serverProcessors,serverArrayDisks,serverFcCards,serverVirtualFlashes,deviceFru,deviceLicense,deviceLocation,deviceManagement,serverMemoryDevices,serverNetworkInterfaces,serverOperatingSystems,serverSupportedPowerStates,serverPowerSupplies,deviceSoftware,serverStorageEnclosures,subsystemRollupStatus)
These are device specific.
A full list can be found by querying the OME API at /api/DeviceService/Devices(DeviceId)/InventoryTypes

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Device[]
## OUTPUTS

## NOTES

## RELATED LINKS
