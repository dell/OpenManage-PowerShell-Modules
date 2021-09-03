---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMETemplateFromFile

## SYNOPSIS
Create template from XML string in OpenManage Enterprise

## SYNTAX

```
New-OMETemplateFromFile [[-Name] <String>] [-Content] <String> [[-TemplateType] <String>] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Perform an export of the System Configuration Profile (SCP) as an example

## EXAMPLES

### EXAMPLE 1
```
" -Wait
```

Create new deployment template from string

### EXAMPLE 2
```
New-OMETemplateFromFile -Name "TestTemplate" -Content $(Get-Content -Path .\Data.xml | Out-String)
```

Create new deployment template from file

### EXAMPLE 3
```
New-OMETemplateFromFile -Name "TestTemplate" -TemplateType "Configuration" -Content $(Get-Content -Path .\Data.xml | Out-String)
```

Create new configuration template from file

## PARAMETERS

### -Name
String that will be assigned the name of the template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "Template $((Get-Date).ToString('yyyyMMddHHmmss'))"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Content
XML string containing template to import

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TemplateType
{{ Fill TemplateType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Deployment
Accept pipeline input: False
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
Position: 4
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [String]Content
## OUTPUTS

## NOTES

## RELATED LINKS
