---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEDirectoryServiceImportGroup

## SYNOPSIS
Import directory group and assign to role from directory service

## SYNTAX

```
Invoke-OMEDirectoryServiceImportGroup [-DirectoryService] <AccountProvider>
 [-DirectoryGroups] <DirectoryGroup[]> [-Role] <Role> [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API.
Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEDirectoryServiceImportGroup -DirectoryService $(Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL") -DirectoryGroups $(Get-OMEDirectoryServiceSearch -Name "Admin" -DirectoryService $(Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL") -DirectoryType "AD" -UserName "Usename@lab.local" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)) -Role $(Get-OMERole -Name "chassis") -Verbose
```

Import directory group

## PARAMETERS

### -DirectoryService
Object of type AccountProvider returned from Get-OMEDirectoryService commandlet

```yaml
Type: AccountProvider
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryGroups
Object of type DirectoryGroup returned from Get-OMEDirectoryServiceSearch commandlet

```yaml
Type: DirectoryGroup[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
Array of Objects of type Role returned from Get-OMERole commandlet

```yaml
Type: Role
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
