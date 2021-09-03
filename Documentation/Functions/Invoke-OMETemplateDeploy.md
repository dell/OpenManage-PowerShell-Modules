---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMETemplateDeploy

## SYNOPSIS
Deploy template to device in OpenManage Enterprise

## SYNTAX

```
Invoke-OMETemplateDeploy [-Template] <Template> [-Devices] <Device[]> [-ForceHostReboot]
 [[-NetworkBootShareType] <String>] [[-NetworkBootShareIpAddress] <String>] [[-NetworkBootIsoPath] <String>]
 [[-NetworkBootIsoTimeout] <String>] [[-NetworkBootShareName] <String>] [[-NetworkBootShareUser] <String>]
 [[-NetworkBootShareWorkGroup] <String>] [[-NetworkBootSharePassword] <String>] [-Wait] [[-WaitTime] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
This will attempt to reboot the server to apply the template.
iDRAC and EventFilter attributes should not cause a reboot but proceed with caution.
As of OME 3.4 only one template can be associated to a device.
However, you can deploy a template to multiple devices.

## EXAMPLES

### EXAMPLE 1
```
"TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -Wait
```

Deploy template

### EXAMPLE 2
```
"TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -NetworkBootShareType "NFS" -NetworkBootShareIpAddress "192.168.1.100" -NetworkBootIsoPath "/mnt/data/iso/CentOS7-Unattended.iso" -Wait -Verbose
```

Deploy template and boot to network ISO over NFS

### EXAMPLE 3
```
"TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -NetworkBootShareType "CIFS" -NetworkBootShareIpAddress "192.168.1.101" -NetworkBootIsoPath "/Share/ISO/CentOS7-Unattended.iso" -NetworkBootShareUser "Administrator" -NetworkBootSharePassword "Password" -NetworkBootShareName "Share" -Wait -Verbose
```

Deploy template and boot to network ISO over CIFS

## PARAMETERS

### -Template
Object of type Template returned from Get-OMETemplate function

```yaml
Type: Template
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Devices
Array of type Device returned from Get-OMEDevice function

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceHostReboot
Forcefully reboot the host OS if the graceful reboot fails.
*This will NOT prevent a reboot of the host, just a forced reboot.
A soft reboot will be initiated upon template deploy.

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

### -NetworkBootShareType
Share type ("NFS", "CIFS")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkBootShareIpAddress
IP Address of the share server

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

### -NetworkBootIsoPath
Full path to the ISO

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkBootIsoTimeout
Lifecycle Controller timeout setting (Default=1) Hour

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkBootShareName
Share name (CIFS Only)

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

### -NetworkBootShareUser
Share user (CIFS Only)

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

### -NetworkBootShareWorkGroup
Share workgroup (CIFS Only)

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

### -NetworkBootSharePassword
Share password (CIFS Only)

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
Position: 11
Default value: 3600
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
