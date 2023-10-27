---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEProfileAssign

## SYNOPSIS
Assign profile to device in OpenManage Enterprise

## SYNTAX

```
Invoke-OMEProfileAssign [-ServerProfile] <Profile> [-TargetId] <Int32> [-AttachAndApply]
 [[-NetworkBootShareType] <String>] [[-NetworkBootShareIpAddress] <String>] [[-NetworkBootIsoPath] <String>]
 [[-NetworkBootIsoTimeout] <Int32>] [[-NetworkBootShareName] <String>] [[-NetworkBootShareUser] <String>]
 [[-NetworkBootShareWorkGroup] <String>] [[-NetworkBootSharePassword] <SecureString>] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This action will assign the profile to a chassis slot or directly to a device.

## EXAMPLES

### EXAMPLE 1
```
See README for examples
```

## PARAMETERS

### -ServerProfile
Object of type Profile returned from Get-OMEProfile function

```yaml
Type: Profile
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TargetId
Integer representing the SlotId for Slot based deployment or DeviceId for device based deployment.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AttachAndApply
Immediately Apply To Compute Sleds.
Only applies to Slot based assignments.
***This will force a reseat of the sled***

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
Type: Int32
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
Type: SecureString
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

### [Profile] $ServerProfile
## OUTPUTS

## NOTES

## RELATED LINKS
