---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMESupportAssistGroup

## SYNOPSIS
Create an MCM group and add all possible members to the created group

## SYNTAX

```
New-OMESupportAssistGroup [[-AddGroup] <String>] [-GenerateJson] [-ExportExampleJson] [<CommonParameters>]
```

## DESCRIPTION
This script uses the OME REST API to create mcm group, find memebers and add the members to the group.

## EXAMPLES

### EXAMPLE 1
```
$TestSupportAssistGroup = '{
    "MyAccountId": "",
    "Name": "Support Assist Group 1",
    "Description": "Support Assist Group",
    "DispatchOptIn": false,
    "CustomerDetails": null,
    "ContactOptIn":  false
}'
New-OMESupportAssistGroup -AddGroup $TestSupportAssistGroup
```

Create new Support Assist group from json stored in variable

### EXAMPLE 2
```
New-OMESupportAssistGroup -AddGroup $(Get-Content "C:\Temp\Group.json" -Raw)
```

Create new Support Assist group from file

### EXAMPLE 3
```
New-OMESupportAssistGroup -ExportExampleJson
```

Export example json

## PARAMETERS

### -AddGroup
JSON string containing group payload.
Use -GenerateJson or -ExportExampleJson for examples

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -GenerateJson
Prompt for values to necessary fields and generate JSON string

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

### -ExportExampleJson
Print example JSON string

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
