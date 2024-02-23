---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEDiscovery

## SYNOPSIS
Create new device discovery job in OpenManage Enterprise

## SYNTAX

```
New-OMEDiscovery [[-Name] <String>] [[-DeviceType] <String>] [-Hosts] <String[]> [[-Protocol] <String>]
 [-DiscoveryUserName] <String> [-DiscoveryPassword] <SecureString> [[-Email] <String>] [-SetTrapDestination]
 [-SetCommunityString] [[-Schedule] <String>] [[-ScheduleCron] <String>] [-UseAllProtocols] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This is used to onboard devices into OpenManage Enterprise.
Specify a list of IP Addresses or hostnames.
You can also specify a subnet.
Wildcards are supported as well.
Only implemented protocols are WSMAN/REDFISH.
Submit an Issue on Github to request additional features.

## EXAMPLES

### EXAMPLE 1
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by hostname

### EXAMPLE 2
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('10.35.0.0', '10.35.0.1') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by IP Address

### EXAMPLE 3
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('10.37.0.0/24') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by Subnet

### EXAMPLE 4
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('10.37.0.0/24') -Schedule "RunLater" -ScheduleCron "0 0 0 ? * sun *" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by Subnet every Sunday at 12:00AM UTC

## PARAMETERS

### -Name
Name of the discovery job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Server Discovery $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceType
Type of device (Default="Server", "Chassis", "Storage", "Network")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Server
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hosts
Array of IP Addresses, Subnets or Hosts
Valid Format:
10.35.0.0
10.36.0.0-10.36.0.255
10.37.0.0/24
2607:f2b1:f083:135::5500/118
2607:f2b1:f083:135::a500-2607:f2b1:f083:135::a600
hostname.domain.tld
hostname
2607:f2b1:f083:139::22a
Invalid IP Range Format:
10.35.0.*
10.36.0.0-255
10.35.0.0/255.255.255.0

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Protocol
Protocol to use for discovery (Default="iDRAC", "SNMP", "IPMI", "SSH", "VMWARE")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: IDRAC
Accept pipeline input: False
Accept wildcard characters: False
```

### -DiscoveryUserName
Discovery user name.
The iDRAC user for server discovery.

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

### -DiscoveryPassword
Discovery password.
The iDRAC user's password for server discovery.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
Email upon completion

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

### -SetTrapDestination
Set trap destination of iDRAC to OpenManage Enterprise upon discovery

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

### -SetCommunityString
Set Community String for trap destination from Application Settings \> Incoming Alerts \> SNMP Listener

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

### -Schedule
Determines when the discovery job will be executed.
(Default="RunNow", "RunLater")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: RunNow
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScheduleCron
Cron string to schedule discovery job at a later time.
Uses UTC time.
Used with -Schedule "RunLater"
Example: Every Sunday at 12:00AM UTC: '0 0 0 ?
* sun *'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0 0 0 ? * sun *
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseAllProtocols
Execute all selected protocols when discovering devices.
This will increase this discovery task's execution time.

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
Position: 10
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
