---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Edit-OMESupportAssistGroup

## SYNOPSIS
Edit Support Assist group in OpenManage Enterprise

## SYNTAX

```
Edit-OMESupportAssistGroup [-Group] <Group> [[-EditGroup] <String>] [[-Devices] <Device[]>] [[-Mode] <String>]
 [<CommonParameters>]
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
$TestSupportAssistGroup = '{
    "MyAccountId": "",
    "Name": "Support Assist Group 2",
    "Description": "Support Assist Group",
    "DispatchOptIn": false,
    "CustomerDetails": null,
    "ContactOptIn":  false
}' 
"Support Assist Group 1" | Get-OMEGroup | Edit-OMESupportAssistGroup -EditGroup $TestSupportAssistGroup -Verbose
```

Edit Support Assist group from json stored in variable

### EXAMPLE 3
```
Get-OMEGroup "Test Group 01" | Edit-OMESupportAssistGroup -EditGroup $(Get-Content "C:\Temp\Group.json" -Raw)
```

Edit Support Assist group from json stored in file

### EXAMPLE 4
```
Get-OMEGroup "Test Group 01" | Edit-OMESupportAssistGroup -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
```

Add devices to group

### EXAMPLE 5
```
Get-OMEGroup "Test Group 01" | Edit-OMESupportAssistGroup -Mode "Remove" -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
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

### -EditGroup
JSON string containing group payload

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

### -Devices
Array of type Device returned from Get-OMEDevice function.

```yaml
Type: Device[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Position: 4
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
