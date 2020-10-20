---
author: Trevor Squillario
category: DELLOPENMANAGE
external help file: DellOpenManage-help.xml
layout: post
Module Name: DellOpenManage
online version:
schema: 2.0.0
tags: OnlineHelp PowerShell
title: New-OMEDiscovery
---

# New-OMEDiscovery

## SYNOPSIS
Create new device discovery job in OpenManage Enterprise

## SYNTAX

```
New-OMEDiscovery [[-Name] <String>] [[-DeviceType] <String>] [-Hosts] <String[]> [-DiscoveryUserName] <String>
 [-DiscoveryPassword] <SecureString> [[-Email] <String>] [-SetTrapDestination] [-Wait] [[-WaitTime] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
This is used to onboard devices into OpenManage Enterprise.
Specify a list of IP Addresses or hostnames.
You can also specify a subnet.
Wildcards are supported as well.

## EXAMPLES

### EXAMPLE 1
```
New-OMEDiscovery -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by hostname

### EXAMPLE 2
```
New-OMEDiscovery -Hosts @('10.35.0.0', '10.35.0.1') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by IP Address

### EXAMPLE 3
```
New-OMEDiscovery -Hosts @('10.37.0.0/24') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Discover servers by Subnet

## PARAMETERS

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Server Discovery
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceType
It can be server,network switch chassis, dell storage

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

### -DiscoveryUserName
{{ Fill DiscoveryUserName Description }}

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

### -DiscoveryPassword
{{ Fill DiscoveryPassword Description }}

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
{{ Fill Email Description }}

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

### -SetTrapDestination
{{ Fill SetTrapDestination Description }}

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
Position: 7
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
