---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Get-OMEAlert

## SYNOPSIS
Retrieves alerts from a target OME Instance.

## SYNTAX

```
Get-OMEAlert [[-Top] <String>] [[-Pages] <Int32>] [[-Skip] <String>] [[-Orderby] <String>] [[-Id] <String>]
 [[-AlertDeviceId] <String>] [[-AlertDeviceIdentifier] <String>] [[-AlertDeviceType] <String>]
 [[-SeverityType] <String>] [[-StatusType] <String>] [[-CategoryName] <String>] [-GetSubcategories]
 [[-SubcategoryId] <String>] [[-SubcategoryName] <String>] [[-Message] <String>] [[-TimeStampBegin] <String>]
 [[-TimeStampEnd] <String>] [[-AlertByDeviceName] <String>] [[-AlertsByGroupName] <String>]
 [[-AlertsByGroupDescription] <String>] [<CommonParameters>]
```

## DESCRIPTION
This script provides a large number of ways to get alerts with various filters.
With no arguments it will pull all
alerts from the OME instance.
The below filters are available:

- top - Pull top records
- skip - Skip N number of records
- orderby - Order by a specific column
- id - Filter by the OME internal event ID
- Alert device ID - Filter by the OME internal ID for the device
- Alert Device Identifier / Service Tag - Filter by the device identifier or service tag of a device
- Device type - Filter by device type (server, chassis, etc)
- Severity type - The severity of the alert - warning, critical, info, etc
- Status type - The status of the device - normal, warning, critical, etc
- Category Name - The type of alert generated.
Audit, configuration, storage, system health, etc
- Subcategory ID - Filter by a specific subcategory.
The list is long - see the --get-subcategories option for details
- Subcategory name - Same as above except the name of the category instead of the ID
- Message - Filter by the message generated with the alert
- TimeStampBegin - Not currently available.
See https://github.com/dell/OpenManage-Enterprise/issues/101
- TimeStampEnd - Not currently available.
See https://github.com/dell/OpenManage-Enterprise/issues/101
- Device name - Filter by a specific device name
- Group name - Filter alerts by a group name
- Group description - Filter alerts by a group description

Authentication is done over x-auth with basic authentication.
Note: Credentials are not stored on disk.

## EXAMPLES

### EXAMPLE 1
```
$creds = Get-Credential
Get-Alerts.ps1 -CategoryName SYSTEM_HEALTH -Top 10
Get-Alerts.ps1 -Top 5 -Skip 3 -Orderby TimeStampAscending -StatusType CRITICAL
```

## PARAMETERS

### -Top
Top records to return.

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

### -Pages
You will generally not need to change this unless you are using a large value for top
- typically more than 50 devices.
In the UI the results come in pages.
Even when
not using the UI the results are still delivered in 'pages'.
The 'top' argument
effectively sets the page size to the value you select and will return *everything*
, albeit much slower, by iterating over all pages in OME.
To prevent this we tell it
to only return a certain number of pages.
By default this value is 1.
If you want
more than one page of results you can set this.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
The number of records, starting at the top, to skip.

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

### -Orderby
Order to apply to the output.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Filter by the OME internal event ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertDeviceId
Filter by OME internal device ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertDeviceIdentifier
Filter by the device identifier.
For servers this is the service tag.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertDeviceType
Filter by device type.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SeverityType
Filter by the severity type of the alert.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StatusType
Filter by status type of the device.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CategoryName
Filter by category name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GetSubcategories
Grabs a list of subcategories from the OME instance.

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

### -SubcategoryId
Filter by subcategory ID.
To get a list of subcategory IDs available run this program 
with the --get-subcategories option.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubcategoryName
Filter by subcategory name.
To get a list of subcategory names available run this 
program with the --get-subcategories option.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Filter by message.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeStampBegin
Filter by starting time of alerts.
This is not currently implemented. 
See: https://github.com/dell/OpenManage-Enterprise/issues/101

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeStampEnd
Filter by ending time of alerts.
This is not currently implemented. 
See: https://github.com/dell/OpenManage-Enterprise/issues/101

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertByDeviceName
{{ Fill AlertByDeviceName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertsByGroupName
The name of the group on which you want to filter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertsByGroupDescription
The description of the group on which you want to filter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
