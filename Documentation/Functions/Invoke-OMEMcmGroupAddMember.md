---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEMcmGroupAddMember

## SYNOPSIS
Add all possible members to MCM Group

## SYNTAX

```
Invoke-OMEMcmGroupAddMember [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API to add all available chassis to the MCM Group

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEMcmGroupAddMember -Wait
```

## PARAMETERS

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
Position: 1
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
