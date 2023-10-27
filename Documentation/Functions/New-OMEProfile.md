---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEProfile

## SYNOPSIS
Create new Profile in OpenManage Enterprise

## SYNTAX

```
New-OMEProfile [-Template] <Template> [-NamePrefix] <String> [[-Description] <String>]
 [-NumberOfProfilesToCreate] <Int32> [[-NetworkBootShareType] <String>] [[-NetworkBootShareIpAddress] <String>]
 [[-NetworkBootIsoPath] <String>] [[-NetworkBootIsoTimeout] <Int32>] [[-NetworkBootShareName] <String>]
 [[-NetworkBootShareUser] <String>] [[-NetworkBootShareWorkGroup] <String>]
 [[-NetworkBootSharePassword] <SecureString>] [<CommonParameters>]
```

## DESCRIPTION
Create new Profile in OpenManage Enterprise

## EXAMPLES

### EXAMPLE 1
```
"Test Template 01" | Get-OMETemplate | New-OMEProfile -NamePrefix "Test Profile" -NumberOfProfilesToCreate 3
```

Create a new Profile from a Template

### EXAMPLE 2
```
"Test Template 01" | Get-OMETemplate | New-OMEProfile -NamePrefix "Test Profile" -NumberOfProfilesToCreate 3 -NetworkBootShareType "NFS" -NetworkBootShareIpAddress "192.168.1.100" -NetworkBootIsoPath "/mnt/data/iso/OS.iso" -Verbose
```

Create a new Profile from a Template and mount ISO from NFS share to Virtual Media

## PARAMETERS

### -Template
{{ Fill Template Description }}

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

### -NamePrefix
Name prefix given to created Profiles

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of Profile

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

### -NumberOfProfilesToCreate
Number of Profiles to create

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: 0
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
Position: 5
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
Position: 6
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
Position: 7
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
Position: 8
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
Position: 9
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
Position: 10
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
Position: 11
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
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [Template] Template
## OUTPUTS

## NOTES

## RELATED LINKS
