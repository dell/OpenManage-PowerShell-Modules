---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Set-OMEApplicationSettings

## SYNOPSIS
Set Application Settings

## SYNTAX

```
Set-OMEApplicationSettings [-Settings] <PSObject[]> [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Set-OMEApplicationSettings -Settings @(@{Name="SSH.1#Enable"; Value=$true}) -Wait -Verbose
Enable SSH. See README for more examples.
```

## PARAMETERS

### -Settings
Array of PSCustomObject (Hashtable) containing Attributes to set.
Use Get-OMEApplicationSettings to view available Attributes.
Example: $Settings = @(@{Name="SSH.1#Enable"; Value=$true})

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
{{ Fill Wait Description }}

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
{{ Fill WaitTime Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
