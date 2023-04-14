---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEQuickDeploy

## SYNOPSIS
Invoke quick deploy job on chassis slots

## SYNTAX

```
Invoke-OMEQuickDeploy [[-Name] <String>] [[-Chassis] <Device>] [-RootPassword] <SecureString>
 [-SlotType] <String> [-IPv4Enabled] [[-IPv4NetworkType] <String>] [[-IPv4SubnetMask] <String>]
 [[-IPv4Gateway] <String>] [-IPv6Enabled] [[-IPv6NetworkType] <String>] [[-IPv6Gateway] <String>]
 [[-IPv6PrefixLength] <Int32>] [-Slots] <PSObject[]> [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEQuickDeploy -RootPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -SlotType "SLED" -Chassis $("C38V9ZZ" | Get-OMEDevice) -IPv4Enabled -IPv4NetworkType "DHCP" -Slots @(@{Slot=1;},@{Slot=2;}) -Wait -Verbose
Quick Deploy sleds in slot 1 and 2 using DHCP. See README for more examples.
```

## PARAMETERS

### -Name
Name of the quick deploy job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Quick Deploy Task Device $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Chassis
Object of type Device returned from Get-OMEDevice function.
Must be a Chassis device type.

```yaml
Type: Device
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RootPassword
SecureString containing the root password

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SlotType
String to represent the slot type (Default="SLED", "IOM")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: SLED
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPv4Enabled
Switch to enable IPv4

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

### -IPv4NetworkType
String to determine the network type (Default="DHCP", "STATIC")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: DHCP
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPv4SubnetMask
String representing the IPv4 subnet mask

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

### -IPv4Gateway
String representing the IPv4 gateway

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

### -IPv6Enabled
Switch to enable IPv6

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

### -IPv6NetworkType
String to determine the network type (Default="DHCP", "STATIC")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: DHCP
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPv6Gateway
String representing the IPv6 gateway

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

### -IPv6PrefixLength
String representing the IPv6 prefix length

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Slots
Array of PSCustomObject (Hashtable) containing slot quick deploy settings.
Example: $Settings = @(@{Slot=1; IPv4Address="192.169.1.100"; IPv6Address="2001:0db8:85a3:0000:0000:8a2e:0370:7334"; VlanId=1})

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 11
Default value: None
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
Position: 12
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Device
## OUTPUTS

## NOTES

## RELATED LINKS
