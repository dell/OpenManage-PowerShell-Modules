---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEMcmGroupRetireLead

## SYNOPSIS
Assign backup lead chassis to MCM Group

## SYNTAX

```
Invoke-OMEMcmGroupRetireLead [[-ServiceTag] <String>] [[-PostRetirementRoleType] <String>] [-Force] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API to create mcm group, find memebers and add the members to the group.

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEMcmGroupRetireLead -Wait
```

## PARAMETERS

### -ServiceTag
Service Tag of chassis to assign as backup lead

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

### -PostRetirementRoleType
{{ Fill PostRetirementRoleType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Member
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
{{ Fill Force Description }}

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
Position: 3
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
