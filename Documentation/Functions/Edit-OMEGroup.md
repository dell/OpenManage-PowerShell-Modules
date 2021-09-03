---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Edit-OMEGroup

## SYNOPSIS
Edit group in OpenManage Enterprise

## SYNTAX

```
Edit-OMEGroup [-Group] <Group> [[-Name] <String>] [[-Description] <String>] [[-Devices] <Device[]>]
 [[-Mode] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup
```

Force group update.
This is a workaround that will trigger baselines to update devices in the associated group.

### EXAMPLE 2
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Name "Test Group 001" -Description "This is a new group"
```

Edit group name and description

### EXAMPLE 3
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
```

Add devices to group

### EXAMPLE 4
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Mode "Remove" -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
```

Remove devices from group

## PARAMETERS

### -Group
Object of type Group returned from Get-OMEGroup function

```yaml
Type: Group
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Name of group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Devices
Array of type Device returned from Get-OMEDevice function.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Mode
Method by which devices are added or removed (Default="Append", "Remove")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Append
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Group
## OUTPUTS

## NOTES

## RELATED LINKS
