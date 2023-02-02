---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# Connect-OMEServer

## SYNOPSIS
Connect to OpenManage Enterprise Server using REST API

## SYNTAX

```
Connect-OMEServer [[-Name] <String>] [[-Credentials] <PSCredential>] [-IgnoreCertificateWarning]
 [<CommonParameters>]
```

## DESCRIPTION
Connect to OpenManage Enterprise Server using REST API.
For authentication session-based X-Auth
Token is used.

Note that the credentials entered are not stored to disk.

## EXAMPLES

### EXAMPLE 1
```
Connect-OMEServer -Name "ome.example.com" -Credentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admin", $(ConvertTo-SecureString -Force -AsPlainText "password")) -IgnoreCertificateWarning
```

### EXAMPLE 2
```
Connect-OMEServer -Name "ome.example.com" -Credentials $(Get-Credential) -IgnoreCertificateWarning
```

Prompt for credentials

### EXAMPLE 3
```
$env:OMEHost = '192.168.1.100'; $env:OMEUserName = 'admin'; $env:OMEPassword = 'calvin'; Connect-OMEServer -IgnoreCertificateWarning
```

Credentials can be stored in Environment Variables

## PARAMETERS

### -Name
OpenManage Enterprise Server Hostname or IP Address.
If not specified will attempt to use Environment Variable OMEHost

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

### -Credentials
PSCredential object containing username and password to authenticate.
If not specified will attempt to use Environment Variables OMEUserName and OMEPassword.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoreCertificateWarning
Ignore certificate warnings from server.
Used for the default self-signed certificate.
(Default=False)

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

### None
## OUTPUTS

## NOTES

## RELATED LINKS
