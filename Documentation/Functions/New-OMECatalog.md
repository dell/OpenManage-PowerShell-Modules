---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMECatalog

## SYNOPSIS
Create new driver/firmware catalog in OpenManage Enterprise

## SYNTAX

```
New-OMECatalog [-Name] <String> [[-Description] <String>] [[-Source] <String>] [[-SourcePath] <String>]
 [[-CatalogFile] <String>] [[-RepositoryType] <String>] [[-DomainName] <String>] [[-Username] <String>]
 [[-Password] <SecureString>] [-CheckCertificate] [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
A catalog is required to update and compare firmware/drivers.
This is the source of the updates to compare your devices against.

## EXAMPLES

### EXAMPLE 1
```
New-OMECatalog -Name "DellOnline" 
Create new catalog from a repository on downloads.dell.com
```

### EXAMPLE 2
```
New-OMECatalog -Name "NFSTest" -RepositoryType "NFS" -Source "nfs01.example.com" -SourcePath "/mnt/data/drm/AllDevices" -CatalogFile "AllDevices_1.01_Catalog.xml"
Create new catalog from a NFS repository
```

### EXAMPLE 3
```
New-OMECatalog -Name "CIFSTest" -RepositoryType "CIFS" -Source "windows01.example.com" -SourcePath "/Share01/DRM/AllDevices" -CatalogFile "AllDevices_1.01_Catalog.xml" -DomainName "example.com" -Username "Administrator" -Password $("P@ssword1" | ConvertTo-SecureString -AsPlainText -Force)
Create new catalog from a CIFS repository
```

## PARAMETERS

### -Name
Name of catalog

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
Description of catalog

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
Hostname or IP Address of server (Default=downloads.dell.com)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Downloads.dell.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourcePath
Directory or share path of server (Default=catalog/catalog.gz)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Catalog/catalog.gz
Accept pipeline input: False
Accept wildcard characters: False
```

### -CatalogFile
Filename of catalog (Default=catalog.xml)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Catalog.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepositoryType
Type of repository ("NFS", "CIFS", "HTTP", "HTTPS", Default="DELL_ONLINE")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: DELL_ONLINE
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainName
Domain name *Only used for CIFS

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

### -Username
Share Username *Only used for CIFS

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
Share Password *Only used for CIFS

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

### -CheckCertificate
Enable certificate check *Only used for HTTPS

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
