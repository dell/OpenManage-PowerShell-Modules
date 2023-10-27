---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEProfile

## SYNOPSIS
Get Profiles managed by OpenManage Enterprise

## SYNTAX

```
Get-OMEProfile [[-Value] <String[]>] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get Profiles.
Returns all Profiles if no input received.

## EXAMPLES

### EXAMPLE 1
```
"ProfileName" | Get-OMEProfile
```

Get Profile by ProfileName

### EXAMPLE 2
```
Get-OMEProfile | Where-Object { $_.ProfileName -eq "Profile from template 'Test Template 01' 00001" }
```

Get Profile by ProfileName where ProfileName includes single quotes.
Use for Profiles deployed from Templates on the MX platform

### EXAMPLE 3
```
"TemplateName" | Get-OMEProfile -FilterBy TemplateName
```

Get Profile by TemplateName

## PARAMETERS

### -Value
String containing search value.
Use with -FilterBy parameter

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilterBy
Filter the results by (Default="ServiceTag", "Name", "Id", "Model", "Type")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Name
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String[]
## OUTPUTS

## NOTES

## RELATED LINKS
