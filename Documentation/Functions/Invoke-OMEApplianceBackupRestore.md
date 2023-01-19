---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEApplianceBackupRestore

## SYNOPSIS
Appliance backup/restore to file on network share

## SYNTAX

```
Invoke-OMEApplianceBackupRestore [[-Name] <String>] [[-Description] <String>] [-IncludePasswords]
 [-IncludeCertificates] [-Share] <String> [-SharePath] <String> [[-ShareType] <String>] [[-Operation] <String>]
 [[-BackupFile] <String>] [-Chassis] <Domain[]> [[-Username] <String>] [[-Password] <SecureString>]
 [-EncryptionPassword] <SecureString> [[-ScheduleCron] <String>] [-Wait] [[-WaitTime] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
Backup or restore appliance to a file on a network share

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Name
Name of the job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Appliance Backup Task $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
{{ Fill Description Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Create a backup of the appliance
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePasswords
{{ Fill IncludePasswords Description }}

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

### -IncludeCertificates
{{ Fill IncludeCertificates Description }}

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

### -Share
{{ Fill Share Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharePath
{{ Fill SharePath Description }}

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

### -ShareType
{{ Fill ShareType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: CIFS
Accept pipeline input: False
Accept wildcard characters: False
```

### -Operation
{{ Fill Operation Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: BACKUP
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupFile
{{ Fill BackupFile Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Chassis
{{ Fill Chassis Description }}

```yaml
Type: Domain[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
{{ Fill Username Description }}

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

### -Password
{{ Fill Password Description }}

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

### -EncryptionPassword
{{ Fill EncryptionPassword Description }}

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScheduleCron
{{ Fill ScheduleCron Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: Startnow
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
Position: 13
Default value: 80
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
