---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEIdentityPoolUsage

## SYNOPSIS
Script to get the list of virtual addresses in an Identity Pool

## SYNTAX

```
Get-OMEIdentityPoolUsage [-IdentityPool] <IdentityPool> [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API to get a list of virtual addresses in an Identity Pool.
Will export to a CSV file called Get-IdentityPoolUsage.csv in the current directory
For authentication X-Auth is used over Basic Authentication
Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
11 | Get-OMEIdentityPool -FilterBy "Id" | Get-OMEIdentityPoolUsage -Verbose
```

Get identity pool by Id

### EXAMPLE 2
```
"Pool01" | Get-OMEIdentityPool | Get-OMEIdentityPoolUsage -Verbose
```

Get identity pool by name

## PARAMETERS

### -IdentityPool
{{ Fill IdentityPool Description }}

```yaml
Type: IdentityPool
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
