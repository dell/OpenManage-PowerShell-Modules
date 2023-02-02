---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Edit-OMEDiscovery

## SYNOPSIS
Edit device discovery job in OpenManage Enterprise

## SYNTAX

```
Edit-OMEDiscovery [-Discovery] <Discovery> [[-Name] <String>] [[-Hosts] <String[]>]
 [-DiscoveryUserName] <String> [-DiscoveryPassword] <SecureString> [[-Email] <String>] [[-Schedule] <String>]
 [[-ScheduleCron] <String>] [[-Mode] <String>] [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This is used to onboard devices into OpenManage Enterprise.
Specify a list of IP Addresses or hostnames.
You can also specify a subnet.
Wildcards are supported as well.

## EXAMPLES

### EXAMPLE 1
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Replace host list and run now

### EXAMPLE 2
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server02-idrac.example.com') -Mode "Append" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Append host to host list and run now

### EXAMPLE 3
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server02-idrac.example.com') -Mode "Remove" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Remove host from host list and run now

### EXAMPLE 4
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunNow" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Run discovery job now

### EXAMPLE 5
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunLater" -ScheduleCron "0 0 0 ? * sun *" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

Run discovery job every Sunday at 12:00AM UTC

## PARAMETERS

### -Discovery
{{ Fill Discovery Description }}

```yaml
Type: Discovery
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Name of the discovery job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "Server Discovery $((Get-Date).ToString('yyyyMMddHHmmss'))"
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

Required: False
Position: 3
Default value: None
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
Position: 4
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
Position: 5
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
Position: 6
Default value: None
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
Position: 7
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
Position: 8
Default value: 0 0 0 ? * sun *
Accept pipeline input: False
Accept wildcard characters: False
```

### -Mode
Method by which hosts are added or removed from discovery job ("Append", Default="Replace", "Remove")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: Replace
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
