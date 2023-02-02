---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEDirectoryServiceSearch

## SYNOPSIS
Search a directory service for groups

## SYNTAX

```
Get-OMEDirectoryServiceSearch [-Name] <Object> [-DirectoryService] <AccountProvider>
 [[-DirectoryType] <String>] [-UserName] <String> [-Password] <SecureString> [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API.
Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
Get-OMEDirectoryServiceSearch -Name "Admin" -DirectoryService $(Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL") -DirectoryType "AD" -UserName "UserName@lab.local" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Verbose | Format-Table
```

## PARAMETERS

### -Name
String containing group name to search

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryService
Object of type AccountProvider returned from Get-OMEDirectoryService commandlet

```yaml
Type: AccountProvider
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
Position: 3
Default value: AD
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username to login to the Directory Service

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

### -Password
Password to login to the Directory Service

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
