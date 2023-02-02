---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEMXDomain

## SYNOPSIS
Get MX domains (chassis) from OpenManage Enterprise

## SYNTAX

```
Get-OMEMXDomain [[-RoleType] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-OMEMXDomain | Format-List
List all domains
```

### EXAMPLE 2
```
"LEAD" | Get-OMEMXDomain | Format-List
```

List lead chassis

### EXAMPLE 3
```
"BACKUPLEAD" | Get-OMEMXDomain | Format-List
```

List backup lead chassis

## PARAMETERS

### -RoleType
Filter the results by role type (Default="ALL", "LEAD", "BACKUPLEAD", "MEMBER")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ALL
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
## OUTPUTS

## NOTES

## RELATED LINKS
