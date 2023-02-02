---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Set-OMETemplateNetwork

## SYNOPSIS
Configure Tagged and UnTagged Networks on a Template

## SYNTAX

```
Set-OMETemplateNetwork [-Template] <Template[]> [[-NICIdentifier] <String>] [[-Port] <Int32>]
 [[-TaggedNetworks] <Network[]>] [[-UnTaggedNetwork] <Network>] [[-PropagateVlan] <Boolean>] [[-Mode] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Configure Tagged and UnTagged Networks on a Template

## EXAMPLES

### EXAMPLE 1
```
"MX740c Template" | Get-OMETemplate | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 1 -TaggedNetworks $("VLAN 1001", "VLAN 1003", "VLAN 1004", "VLAN 1005" | Get-OMENetwork) -Verbose
```

Set tagged networks on NIC port 1

### EXAMPLE 2
```
For more examples visit https://github.com/dell/OpenManage-PowerShell-Modules/blob/main/README.md
```

## PARAMETERS

### -Template
Object of type Template returned from Get-OMETemplate

```yaml
Type: Template[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -NICIdentifier
String identifing the NIC (Example: "NIC in Mezzanine 1A")

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

### -Port
Integer identifing the Port number (Example: 1)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaggedNetworks
Array of type Network returned from Get-OMENetwork function.

```yaml
Type: Network[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnTaggedNetwork
Object of type Network returned from Get-OMENetwork function.
In most instances we want to omit this parameter.
The Untagged network will default to VLAN 1.

```yaml
Type: Network
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PropagateVlan
Boolean value that will determine if VLAN settings are propagated immediately without having to re-deploy the template (Default=$true)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Mode
String specifing operation to perform on TaggedNetworks and UnTaggedNetwork, required with -TaggedNetworks or -UnTaggedNetwork ("Append", "Replace", "Remove")

```yaml
Type: String
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

### Template
## OUTPUTS

## NOTES

## RELATED LINKS
