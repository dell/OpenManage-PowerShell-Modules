---
external help file: DellOpenManage-help.xml
Module Name: DellOpenManage
online version:
schema: 2.0.0
---

# New-OMEDirectoryService

## SYNOPSIS
Create new static group in OpenManage Enterprise

## SYNTAX

```
New-OMEDirectoryService [-Name] <String> [[-DirectoryType] <String>] [[-DirectoryServerLookup] <String>]
 [-DirectoryServers] <String[]> [[-ADGroupDomain] <String>] [[-ServerPort] <Int32>] [[-NetworkTimeOut] <Int32>]
 [[-SearchTimeOut] <Int32>] [-CertificateValidation] [[-CertificateFile] <String>]
 [[-LDAPBindUserName] <String>] [[-LDAPBindPassword] <SecureString>] [[-LDAPBaseDistinguishedName] <String>]
 [[-LDAPAttributeUserLogin] <String>] [[-LDAPAttributeGroupMembership] <String>] [[-LDAPSearchFilter] <String>]
 [-TestConnection] [[-TestUserName] <String>] [[-TestPassword] <SecureString>] [<CommonParameters>]
```

## DESCRIPTION
Only static groups are supported currently.
Raise an issue on Github for query group support.

## EXAMPLES

### EXAMPLE 1
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" -DirectoryServerLookup "DNS" -DirectoryServers @("lab.local") -ADGroupDomain "lab.local" -TestConnection -TestUserName "Username@lab.local" -TestPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Verbose
```

Test AD Directory Service using Global Catalog Lookup

### EXAMPLE 2
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" -DirectoryServerLookup "DNS" -DirectoryServers @("lab.local") -ADGroupDomain "lab.local"
```

Create AD Directory Service using Global Catalog Lookup

### EXAMPLE 3
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" -DirectoryServerLookup "DNS" -DirectoryServers @("lab.local") -ADGroupDomain "lab.local" -CertificateValidation -CertificateFile "C:\Temp\CA.cer"
```

Create AD Directory Service using Global Catalog Lookup with Certificate Validation

### EXAMPLE 4
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" -DirectoryServerLookup "MANUAL" -DirectoryServers @("ad1.lab.local", "ad2.lab.local") -ADGroupDomain "lab.local"
```

Create AD Directory Service manually specifing Domain Controllers

### EXAMPLE 5
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "LDAP" -DirectoryServerLookup "MANUAL" -DirectoryServers @("ldap1.lab.local", "ldap2.lab.local") -LDAPBaseDistinguishedName "dc=lab,dc=local"
```

Create LDAP Directory Service

## PARAMETERS

### -Name
Name of group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryType
Directory type (Default="AD", "LDAP")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: AD
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryServerLookup
Directory server lookup type.
DNS will use automatically lookup Directory Servers (Domain Controllers).
MANUAL you must provide them.
(Default="DNS", "MANUAL")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: DNS
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryServers
Directory servers by hostname, fqdn or IP.
For DirectoryServerLookup=DNS DirectoryServers must contain only 1 entry Example: lab.local.
For DirectoryServerLookup=MANUAL provide an array of servers.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ADGroupDomain
Name of the domain Example: lab.local

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

### -ServerPort
Port to use when communicating with directory server

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkTimeOut
Network timeout

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 120
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchTimeOut
Search timeout

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 120
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateValidation
Provide certificate validation.
To be used with CertificateFile (NOT IMPLEMENTED)

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

### -CertificateFile
Path to directory certificate.
Required when -CertificateValidation switch provided

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

### -LDAPBindUserName
Username to use when connecting to LDAP server

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

### -LDAPBindPassword
Password to use when connecting to LDAP server

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LDAPBaseDistinguishedName
Base search DN for LDAP

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

### -LDAPAttributeUserLogin
LDAP attribute to use for username

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

### -LDAPAttributeGroupMembership
LDAP attribute to use for group membership

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

### -LDAPSearchFilter
LDAP base search filter

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

### -TestConnection
Test directory service connection.
When provided it will only test the connection and not create directory service.

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

### -TestUserName
Username to use when testing directory service connection

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

### -TestPassword
Password to use when testing directory service connection

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
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
