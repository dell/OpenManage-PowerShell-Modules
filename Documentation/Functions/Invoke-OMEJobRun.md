---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEJobRun

## SYNOPSIS
Run job now

## SYNTAX

```
Invoke-OMEJobRun [-JobId] <Int32> [-Wait] [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Run an existing job by Id

## EXAMPLES

### EXAMPLE 1
```
28991 | Invoke-OMEJobRun -Wait -Verbose
```

Run job

## PARAMETERS

### -JobId
Integer containing JobId

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Wait
Wait for job to complete

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
Time, in seconds, to wait for the job to complete

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

### [int] JobId
## OUTPUTS

## NOTES

## RELATED LINKS
