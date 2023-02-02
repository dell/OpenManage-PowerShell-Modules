---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEFabricUplink

## SYNOPSIS
Create a fabric uplink

## SYNTAX

```
New-OMEFabricUplink [-Name] <String> [[-Description] <String>] [-Fabric] <Fabric> [-UplinkType] <String>
 [-UplinkFailureDetection] [-Ports] <String> [[-TaggedNetworks] <Network[]>] [[-UnTaggedNetwork] <Network>]
 [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API to create a smart fabric uplink

## EXAMPLES

### EXAMPLE 1
```
New-OMEFabricUplink -Name "EthernetUplink01" -Fabric $("SmartFabric01" | Get-OMEFabric) -UplinkType "Ethernet - No Spanning Tree" -TaggedNetworks $("VLAN 1001", "VLAN 1003" | Get-OMENetwork) -Ports "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1" -Verbose
```

Create ethernet uplink

### EXAMPLE 2
```
For more examples visit https://github.com/dell/OpenManage-PowerShell-Modules/blob/main/README.md
```

## PARAMETERS

### -Name
Name of the uplink

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
Description of the uplink

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

### -Fabric
Object of type Fabric returned from Get-OMEFabric

```yaml
Type: Fabric
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UplinkType
{{ Fill UplinkType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UplinkFailureDetection
Add the uplink to the Uplink Failure Detection (UFD) group

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

### -Ports
Comma delimited string containing uplink ports (Example: C38S9T2:ethernet1/1/41:2,CMWSV43:ethernet1/1/41:2)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaggedNetworks
Array of type Network returned from Get-OMENetwork

```yaml
Type: Network[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnTaggedNetwork
Object of type Network returned from Get-OMENetwork

```yaml
Type: Network
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
