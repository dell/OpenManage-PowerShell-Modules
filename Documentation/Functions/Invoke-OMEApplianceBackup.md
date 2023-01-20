---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEApplianceBackup

## SYNOPSIS
Appliance backup to file on network share.
Restore must be performed in OME-M at this time.

## SYNTAX

```
Invoke-OMEApplianceBackup [[-Name] <String>] [[-Description] <String>] [-IncludePw] [-IncludeCertificates]
 [-Share] <String> [-SharePath] <String> [[-ShareType] <String>] [[-BackupFile] <String>] [-Chassis] <Domain[]>
 [[-UserName] <String>] [[-Password] <SecureString>] [-EncryptionPassword] <SecureString>
 [[-ScheduleCron] <String>] [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Backup appliance to a file on a network share

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEApplianceBackup -Chassis @("LEAD" | Get-OMEMXDomain | Select-Object -First 1) -Share "192.168.1.100" -SharePath "/SHARE" -ShareType "CIFS" -UserName "Administrator" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose
```

Backup chassis to CIFS share now

### EXAMPLE 2
```
Invoke-OMEApplianceBackup -Chassis  @("LEAD" | Get-OMEMXDomain | Select-Object -First 1) -Share "192.168.1.100" -SharePath "/mnt/data/backup" -ShareType "NFS" -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" -ScheduleCron '0 0 0 ? * sun *' -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose
```

Backup chassis to NFS share on schedule

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
Job description

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

### -IncludePw
Include passwords in backup

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
Include certificates in backup

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
Share host IP address or hostname

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
Share directory path

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
Share type ("NFS", Default="CIFS", "HTTP", "HTTPS")

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

### -BackupFile
Backup file name, .bin is automatically appended to file name.
Default=BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Chassis
Lead or standalone chassis to backup or restore to.
Object of type Domain returned from Get-OMEMXDomain

```yaml
Type: Domain[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Used for CIFS .
Username to connect to share

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

### -Password
Used for CIFS .
Password to connect to share

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EncryptionPassword
Password used to encrypt backup

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScheduleCron
Specify cron string to schedule the job in the future.
Leave out to run now.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
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
Position: 12
Default value: 80
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
