---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Copy-OMETemplate

## SYNOPSIS
Clone template in OpenManage Enterprise.
***Only supports Deployment templates

## SYNTAX

```
Copy-OMETemplate [-Template] <Template> [[-Name] <String>] [-All] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
"TestTemplate01" | Get-OMETemplate | Copy-OMETemplate
```

Clone template using default name "TestTemplate01 - Clone"

### EXAMPLE 2
```
$(Get-OMETemplate | Where-Object -Property "Name" -EQ "TestTemplate") | Copy-OMETemplate
```

Clone template using default name "TestTemplate01 - Clone" when multiple templates with similar names exist

### EXAMPLE 3
```
"TestTemplate01" | Get-OMETemplate | Copy-OMETemplate -Name "TestTemplate02"
```

Clone template and specify new name

### EXAMPLE 4
```
"TestTemplate01" | Get-OMETemplate | Copy-OMETemplate -All
```

Clone template including Identity Pool, VLANs and Teaming

## PARAMETERS

### -Template
Single Template object returned from Get-OMEDevice function.
Only supports Deployment templates

```yaml
Type: Template
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
String that will be assigned the name of the template

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

### -All
Clone all template attributes including Identity Pool, VLANs and Teaming

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

### [Template]Template
## OUTPUTS

### [int]TemplateId
## NOTES

## RELATED LINKS
