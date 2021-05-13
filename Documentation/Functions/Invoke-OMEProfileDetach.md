---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEProfileDetach

## SYNOPSIS
Detach profile from device in OpenManage Enterprise

## SYNTAX

```
Invoke-OMEProfileDetach [[-Devices] <Device[]>] [[-Template] <Template>] [[-ProfileName] <String>] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This action will unassign the profile(s) from all selected targets, disassociating the profile(s) from target(s).
The server will be forcefully rebooted in order to remove any deployed identities from applicable devices.
As of OME 3.4 only one template can be associated to a device.
However, you can deploy a template to multiple devices.

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEProfileDetach -Devices $("37KP0ZZ", "GV6V0ZZ" | Get-OMEDevice) -Wait -Verbose
Unassign profile by device
```

### EXAMPLE 2
```
Invoke-OMEProfileDetach -Template $("TestTemplate01" | Get-OMETemplate) -Wait -Verbose
Unassign profile by template
```

### EXAMPLE 3
```
Invoke-OMEProfileDetach -ProfileName "Profile from template 'TestTemplate01' 00001" -Wait -Verbose
Unassign profile by profile name
```

## PARAMETERS

### -Devices
Array of type Device returned from Get-OMEDevice function

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Template
Object of type Template returned from Get-OMETemplate function

```yaml
Type: Template
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
Name of Profile to detach.
Uses contains style operator and supports partial string matching.

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
Position: 4
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Devices
## OUTPUTS

## NOTES

## RELATED LINKS
