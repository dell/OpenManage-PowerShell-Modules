---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMESupportAssistCase

## SYNOPSIS
Get list of Identity Pools from OME

## SYNTAX

```
Get-OMESupportAssistCase [[-Value] <Object>] [[-FilterBy] <String>] [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API.
Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
Get-OMESupportAssistCase | Format-Table
```

## PARAMETERS

### -Value
String containing search value.
Use with -FilterBy parameter.
Supports regex based matching.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilterBy
Filter the results by ("EventSource", "Id", "ServiceContract", Default="ServiceTag")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ServiceTag
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
