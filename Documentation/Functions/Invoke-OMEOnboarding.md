---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Invoke-OMEOnboarding

## SYNOPSIS
Update onboarding credentials on devices in OpenManage Enterprise

## SYNTAX

```
Invoke-OMEOnboarding [[-Name] <String>] [[-Devices] <Device[]>] [-OnboardingUserName] <String>
 [-OnboardingPassword] <SecureString> [-SetRedfish] [-SetTrapDestination] [-SetCommunityString] [-Wait]
 [[-WaitTime] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Change onboarding credentials for device and submit an onboarding job to update device credentials in OME

## EXAMPLES

### EXAMPLE 1
```
Invoke-OMEOnboarding -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model") -OnboardingUserName "admin" -OnboardingPassword $(ConvertTo-SecureString "calvin" -AsPlainText -Force)
Change onboarding credentials
```

## PARAMETERS

### -Name
Name of the job

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "OnBoarding Task $((Get-Date).ToString('yyyyMMddHHmmss'))"
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
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OnboardingUserName
OnBoarding user name.
The iDRAC user for server onboarding.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnboardingPassword
OnBoarding password.
The iDRAC user's password for server onboarding.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetRedfish
Sets REDFISH as well as WSMAN onboarding credentials.
Typically required devices discovered using OME 3.9 and newer.
Use this parameter if you receive the error "Unable to complete the operation because the value provided for {0} is invalid."

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

### -SetTrapDestination
Set trap destination of iDRAC to OpenManage Enterprise

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

### -SetCommunityString
Set Community String for trap destination from Application Settings \> Incoming Alerts \> SNMP Listener

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
Position: 5
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Device
## OUTPUTS

## NOTES

## RELATED LINKS
