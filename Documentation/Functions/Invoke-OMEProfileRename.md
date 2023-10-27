---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEProfileRename

## SYNOPSIS
Rename profile

## SYNTAX

```
Invoke-OMEProfileRename [-ServerProfile] <Profile> [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Rename existing profile

## EXAMPLES

### EXAMPLE 1
```
"Profile 00005" | Get-OMEProfile | Invoke-OMEProfileRename -Name "Test Profile 00005"
```

Rename Profile

### EXAMPLE 2
```
Get-OMEProfile | Where-Object { $_.ProfileName -eq "Profile from template 'Test Template 01' 00001" } | Invoke-OMEProfileRename -Name "Test Profile 01 - 00001"
```

Rename Profile deployed from Template on MX platform

## PARAMETERS

### -ServerProfile
Object of type Profile returned from Get-OMEProfile

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

### -Name
{{ Fill Name Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [Profile] Profile
## OUTPUTS

## NOTES

## RELATED LINKS
