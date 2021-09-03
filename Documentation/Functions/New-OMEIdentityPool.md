---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEIdentityPool

## SYNOPSIS
Create new Identity Pool in OpenManage Enterprise

## SYNTAX

```
New-OMEIdentityPool [-Name] <String> [-Description] <String> [[-EthernetSettings_IdentityCount] <Int32>]
 [[-EthernetSettings_StartingMacAddress] <String>] [[-IscsiSettings_IdentityCount] <Int32>]
 [[-IscsiSettings_StartingMacAddress] <String>] [[-IscsiSettings_InitiatorConfig_IqnPrefix] <String>]
 [[-IscsiSettings_InitiatorIpPoolSettings_IpRange] <String>]
 [[-IscsiSettings_InitiatorIpPoolSettings_SubnetMask] <String>]
 [[-IscsiSettings_InitiatorIpPoolSettings_Gateway] <String>]
 [[-IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer] <String>]
 [[-IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer] <String>] [[-FcoeSettings_IdentityCount] <Int32>]
 [[-FcoeSettings_StartingMacAddress] <String>] [[-FcSettings_Wwnn_IdentityCount] <Int32>]
 [[-FcSettings_Wwnn_StartingAddress] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
New-OMEIdentityPool `
-Name "TestPool01" `
-Description "Test Pool 01" `
-EthernetSettings_IdentityCount 5 `
-EthernetSettings_StartingMacAddress "AA:BB:CC:DD:F5:00" `
-IscsiSettings_IdentityCount 5 `
-IscsiSettings_StartingMacAddress "AA:BB:CC:DD:F6:00" `
-IscsiSettings_InitiatorConfig_IqnPrefix "iqn.2009-05.com.test:test" `
-IscsiSettings_InitiatorIpPoolSettings_IpRange "192.168.1.200-192.168.1.220" `
-IscsiSettings_InitiatorIpPoolSettings_SubnetMask "255.255.255.0" `
-IscsiSettings_InitiatorIpPoolSettings_Gateway "192.168.1.1" `
-IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer "192.168.1.10" `
-IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer "192.168.1.11" `
-FcoeSettings_IdentityCount 5 `
-FcoeSettings_StartingMacAddress "AA:BB:CC:DD:F7:00" `
-FcSettings_Wwnn_IdentityCount 5 `
-FcSettings_Wwnn_StartingAddress "AA:BB:CC:DD:F8:00" `
-Verbose
```

Create a new static IdentityPool

## PARAMETERS

### -Name
{{ Fill Name Description }}

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
Description of IdentityPool

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EthernetSettings_IdentityCount
{{ Fill EthernetSettings_IdentityCount Description }}

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

### -EthernetSettings_StartingMacAddress
{{ Fill EthernetSettings_StartingMacAddress Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_IdentityCount
{{ Fill IscsiSettings_IdentityCount Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_StartingMacAddress
{{ Fill IscsiSettings_StartingMacAddress Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_InitiatorConfig_IqnPrefix
{{ Fill IscsiSettings_InitiatorConfig_IqnPrefix Description }}

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

### -IscsiSettings_InitiatorIpPoolSettings_IpRange
{{ Fill IscsiSettings_InitiatorIpPoolSettings_IpRange Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_InitiatorIpPoolSettings_SubnetMask
{{ Fill IscsiSettings_InitiatorIpPoolSettings_SubnetMask Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_InitiatorIpPoolSettings_Gateway
{{ Fill IscsiSettings_InitiatorIpPoolSettings_Gateway Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer
{{ Fill IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer
{{ Fill IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FcoeSettings_IdentityCount
{{ Fill FcoeSettings_IdentityCount Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FcoeSettings_StartingMacAddress
{{ Fill FcoeSettings_StartingMacAddress Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FcSettings_Wwnn_IdentityCount
{{ Fill FcSettings_Wwnn_IdentityCount Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FcSettings_Wwnn_StartingAddress
{{ Fill FcSettings_Wwnn_StartingAddress Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
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
