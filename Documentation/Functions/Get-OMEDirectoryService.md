---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEDirectoryService

## SYNOPSIS
Get list of directory services that provide user authentication

## SYNTAX

```
Get-OMEDirectoryService [[-Name] <String>] [[-DirectoryType] <String>] [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API.
Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
Get-OMEDirectoryService -DirectoryType "AD" | Format-Table
```

Get all by type

### EXAMPLE 2
```
Get-OMEDirectoryService -DirectoryType "AD" -Name "OSE.LOCAL" -Verbose | Format-Table
```

Get by name of type AD

### EXAMPLE 3
```
Get-OMEDirectoryService -DirectoryType "LDAP" -Name "OSE.LOCAL" -Verbose | Format-Table
```

Get by name of type LDAP

## PARAMETERS

### -Name
String containing group name to search

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryType
Directory type (Default="AD", "LDAP")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: AD
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
