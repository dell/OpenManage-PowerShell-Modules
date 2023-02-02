---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Remove-OMENetwork

## SYNOPSIS
Remove network

## SYNTAX

```
Remove-OMENetwork [-Network] <Network> [<CommonParameters>]
```

## DESCRIPTION
Remove network

## EXAMPLES

### EXAMPLE 1
```
"TestNetwork01" | Get-OMENetwork | Remove-OMENetwork
```

Remove network

## PARAMETERS

### -Network
Object of type Network returned from Get-OMENetwork

```yaml
Type: Network
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

### None
## OUTPUTS

## NOTES

## RELATED LINKS
