---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEUser

## SYNOPSIS
Create new user in OpenManage Enterprise

## SYNTAX

```
New-OMEUser [-Name] <String> [-Password] <SecureString> [[-Description] <String>] [-Role] <String>
 [[-Locked] <Boolean>] [[-Enabled] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
New-OMEUser -Name "tstest1" -Description "Test user 1" -Password $(ConvertTo-SecureString -Force -AsPlainText "calvin") -Role "ADMINISTRATOR"
```

Create a new user

## PARAMETERS

### -Name
Name of user

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

### -Password
Password of user

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
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
Position: 3
Default value: User created via the OME API.
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
Role of user ("VIEWER", "DEVICE_MANAGER", "ADMINISTRATOR")

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

### -Locked
Description of user (True, Default=False)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Description of user (Default=True, False)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: True
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
