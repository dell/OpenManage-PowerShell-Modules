# DellOpenManage Powershell Module

# Install Module

## Requirements
- PowerShell 5+
- OpenManage Enterprise 3.4+
- OpenManage Enterprise Modular 1.20.00+

## PowerShell Gallery Installation
`Install-Module -Name DellOpenManage -Scope CurrentUser`

## Scripted Installation
1. Open PowerShell Command Window
2. Change your PowerShell Execution Policy `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. CD to the directory where you cloned the Github repo
4. .\Install-Module.ps1

## Manual Installation
1. Determine module path `$Env:PSModulePath`
    * PowerShell 5: C:\Users\username\Documents\WindowsPowerShell\Modules
    * PowerShell 6+: C:\Users\username\Documents\PowerShell\Modules
2. Copy the DellOpenManage folder to a directory in your module path
    * Example: C:\Users\username\Documents\WindowsPowerShell\Modules\DellOpenManage
3. List available Modules `Get-Module Dell* -ListAvailable`
4. Import module `Import-Module DellOpenManage`

## Contributing
See [Contributing](CONTRIBUTE.md)

# Command Reference
See [Command Reference](Documentation/CommandReference.md)

## Getting Started
See if Module is available
```
Get-Module Dell* -ListAvailable
```
List available commandlets in Module
```
Get-Command -Module "DellOpenManage"
```
Show help for commandlet
```
Get-Help Connect-OMEServer -Detailed
```
### Basic Example
* Copy and paste these commands into a Test.ps1 script or PowerShell ISE and execute the script.
* This will Import the Module, connect to server prompting for credentials, list servers by model, then disconnect the current session.
```
Import-Module DellOpenManage

Connect-OMEServer -Name "ome.example.com" -Credentials $(Get-Credential) -IgnoreCertificateWarning

"PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Format-Table

Disconnect-OMEServer
```

## Connect
Connect
```
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admin", $(ConvertTo-SecureString -Force -AsPlainText "password")
Connect-OMEServer -Name "ome.example.com" -Credentials $credentials -IgnoreCertificateWarning
```
Connect: Variables
```
. "C:\Path\To\Credentials.ps1"
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning
```
Connect: Prompt for Credentials
```
$credentials = Get-Credential
Connect-OMEServer -Name "ome.example.com" -Credentials $credentials -IgnoreCertificateWarning
```

## Discovery
Discover servers by hostname
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait
```
Discover servers by IP Address
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('10.35.0.0', '10.35.0.1') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait
```
Discover servers by Subnet
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('10.37.0.0/24') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait
```
Discover servers by Subnet every Sunday at 12:00AM UTC
```
New-OMEDiscovery -Name "TestDiscovery01" -Hosts @('10.37.0.0/24') -Schedule "RunLater" -ScheduleCron "0 0 0 ? * sun *" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```
Replace host list and run now
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```
Append host to host list and run now
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server02-idrac.example.com') -Mode "Append" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```
Remove host from host list and run now
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server02-idrac.example.com') -Mode "Remove" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```
Run discovery job now
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunNow" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```
Run discovery job every Sunday at 12:00AM UTC
```
"TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunLater" -ScheduleCron "0 0 0 ? * sun *" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
```

## Devices
Get device by id
```
10097, 10100 | Get-OMEDevice -FilterBy "Id" | Format-Table
```
Get device by service tag
```
"C86F0ZZ", "3XMHHZZ" | Get-OMEDevice -FilterBy "ServiceTag" | Format-Table
```
Get device by name
```
"R620.example.com" | Get-OMEDevice -FilterBy "Name" | Format-Table
```
Get device by model
```
"PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Format-Table
```
Get device by group
```
Get-OMEDevice -Group $(Get-OMEGroup "Servers_Win") | Format-Table
"Servers_ESXi", "Servers_Win" | Get-OMEGroup | Get-OMEDevice | Format-Table
```
Create separate inventory refresh job for each device in list
```
"PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Invoke-OMEInventoryRefresh -Verbose
```
Create one inventory refresh job for all devices in list. Notice the preceeding comma before the device list.
```
,$("PowerEdge R640" | Get-OMEDevice -FilterBy "Model") | Invoke-OMEInventoryRefresh -Verbose
```

## Device Details
Get all inventory
```
10097, 10100 | Get-OMEDevice -FilterBy "Id" | Get-OMEDeviceDetail
```
Get network cards and mac addresses
```
"C39P9ZZ", "C39N9ZZ" | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "serverNetworkInterfaces" | Format-Table
```
Get firmware inventory
```
"C39P9ZZ", "C39N9ZZ" | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "deviceSoftware" | Format-Table
```
Inventory Types

These are device specific. A full list can be found by querying the OME API at /api/DeviceService/Devices(DeviceId)/InventoryTypes
```
deviceCapabilities
serverDeviceCards
chassisControllerList
chassisFansList
chassisPciDeviceList
chassisPowerSupplies
chassisSlotsList
chassisStorageComputeAssociations
chassisTemperatureList
serverRaidControllers
serverProcessors
serverArrayDisks
serverFcCards
serverVirtualFlashes
deviceFru
deviceLicense
deviceLocation
deviceManagement
serverMemoryDevices
serverNetworkInterfaces
serverOperatingSystems
serverSupportedPowerStates
serverPowerSupplies
deviceSoftware
serverStorageEnclosures
subsystemRollupStatus
```

## Groups
Get all groups
```
Get-OMEGroup | Format-Table
```
Get group by name
```
Get-OMEGroup "R640Test" | Format-Table
```
Create a new static group
```
New-OMEGroup -Name "Test Group 01"
```
Edit group name and description
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Name "Test Group 001" -Description "This is a new group"
```
Add devices to group
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
```
Remove devices from group
```
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Mode "Remove" -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
```
Remove group
```
Get-OMEGroup "Test Group 01" | Remove-OMEGroup
```

## Power
Power on server
```
Set-OMEPowerState -State "On" -Devices $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag")
```

## Firmware
Create new firmware catalog that points to downloads.dell.com
```
New-OMECatalog -Name "Test01"
```
Create new firmware catalog to a CIFS share (Requires Dell Repository Manager)
```
New-OMECatalog -Name "CIFSTest" -RepositoryType "CIFS" -Source "windows01.example.com" -SourcePath "/Share01/DRM/AllDevices" -CatalogFile "AllDevices_1.01_Catalog.xml" -DomainName "example.com" -Username "Administrator" -Password $("P@ssword1" | ConvertTo-SecureString -AsPlainText -Force)
```
Create new firmware catalog to a NFS share (Requires Dell Repository Manager)
```
New-OMECatalog -Name "NFSTest" -RepositoryType "NFS" -Source "nfs01.example.com" -SourcePath "/mnt/data/drm/AllDevices" -CatalogFile "AllDevices_1.01_Catalog.xml"
```
Get firmware catalog
```
Get-OMECatalog | Format-Table
"DRM" | Get-OMECatalog | Format-Table
```
Get firmware baseline
```
Get-OMEFirmwareBaseline | Format-Table
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance | Format-Table
```
Get device firmware compliance report
```
$devices = $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag")
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -DeviceFilter $devices |
    Select-Object -Property ServiceTag,DeviceModel,DeviceName,CurrentVersion,Version,UpdateAction,ComplianceStatus,Name | Format-Table
```
Get device firmware compliance report. BIOS only.
```
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -ComponentFilter "BIOS" |
    Select-Object -Property ServiceTag,DeviceModel,DeviceName,CurrentVersion,Version,UpdateAction,ComplianceStatus,Name |
    Sort-Object CurrentVersion | Format-Table
```
Create new firmware baseline
```
$catalog = $("Auto-Update-Online" | Get-OMECatalog)
$devices = $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag")
New-OMEFirmwareBaseline -Name "TestBaseline01" -Catalog $catalog -Devices $devices
```
Create new firmware baseline for downgrades
```
$catalog = $("Auto-Update-Online" | Get-OMECatalog)
$devices = $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag")
New-OMEFirmwareBaseline -Name "TestBaseline01" -Catalog $catalog -Devices $devices -AllowDowngrade
```
Display device compliance report for all devices in baseline. No updates are installed by default.
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) | Format-Table
```
Update firmware on all devices in baseline immediately ***Warning: This will force a reboot of all servers
```
$devices = $("CY85DZZ" | Get-OMEDevice -FilterBy "ServiceTag")
$baseline = $("AllLatest" | Get-OMEFirmwareBaseline)
Update-OMEFirmware -Baseline $baseline -UpdateSchedule "RebootNow" -Wait
```
Update firmware on all devices in baseline on next reboot
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot"
```
Update firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow" -Wait
```
Downgrade firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow" -UpdateAction "Downgrade" -Wait
```
Update firmware on specific components in baseline on next reboot and clear job queue
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -ComponentFilter "iDRAC" -UpdateSchedule "StageForNextReboot" -ClearJobQueue
```
Update firmware later scheduled at 11/1/2020 12:00AM UTC
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "ScheduleLater" -UpdateScheduleCron "0 0 0 1 11 ?"
```

## Templates
Get all templates
```
Get-OMETemplate | Format-Table
```
Get template by name
```
"DRM" | Get-OMETemplate | Format-Table
```
Get template by type
```
"Deployment" | Get-OMETemplate -FilterBy "Type" | Format-Table
```
Get template when templates with similar names exist
```
Get-OMETemplate | Where-Object -Property "Name" -EQ "Test Template "
```
Create new deployment template from source device
```
New-OMETemplateFromDevice -Name "TestTemplate" -Device $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait
```
Create new deployment template from source device and capture specific components
```
New-OMETemplateFromDevice -Name "TestTemplate" -Component "iDRAC", "BIOS" -Device $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait
```
Create new deployment template from XML string
```
$xml = @'
<SystemConfiguration>
    <Component FQDD="iDRAC.Embedded.1">
        <Attribute Name="Users.5#UserName">testuser</Attribute>
    </Component>
</SystemConfiguration>
'@
New-OMETemplateFromFile -Name "TestTemplate" -Content $xml
```
Create new deployment template from XML file
```
New-OMETemplateFromFile -Name "TestTemplate" -Content $(Get-Content -Path .\Data.xml | Out-String)
```
Deploy template to device
```
"TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -Wait
```
Deploy template and boot to network ISO over NFS
```
"TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -NetworkBootShareType "NFS" -NetworkBootShareIpAddress "192.168.1.100" -NetworkBootIsoPath "/mnt/data/iso/CentOS7-Unattended.iso" -Wait
```
Deploy template and boot to network ISO over CIFS
```
"TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -NetworkBootShareType "CIFS" -NetworkBootShareIpAddress "192.168.1.101" -NetworkBootIsoPath "/Share/ISO/CentOS7-Unattended.iso" -NetworkBootShareUser "Administrator" -NetworkBootSharePassword "Password" -NetworkBootShareName "Share" -Wait
```
Clone template using default name "TestTemplate01 - Clone"
```
"TestTemplate01" | Get-OMETemplate | Copy-OMETemplate
```
Clone template using default name "TestTemplate01 - Clone" when multiple templates with similar names exist
```
$(Get-OMETemplate | Where-Object -Property "Name" -EQ "TestTemplate") | Copy-OMETemplate
```
Clone template and specify new name
```
"TestTemplate01" | Get-OMETemplate | Copy-OMETemplate -Name "TestTemplate02"
```
Clone template including Identity Pool, VLANs and Teaming
```
"TestTemplate01" | Get-OMETemplate | Copy-OMETemplate -All
``` 

## Configuration Compliance
Get template by type
```
"Configuration" | Get-OMETemplate -FilterBy "Type" | Format-Table
```
Create new configuration compliance template from source device
```
New-OMETemplateFromDevice -Name "TestTemplate" -TemplateType "Configuration" -Device $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait
```
Create new configuration compliance template from XML file
```
New-OMETemplateFromFile -Name "TestTemplate" -TemplateType "Configuration" -Content $(Get-Content -Path .\Data.xml | Out-String)
```
Create new configuration compliance baseline
```
New-OMEConfigurationBaseline -Name "TestBaseline01" -Template $("Template01" | Get-OMETemplate -FilterBy "Name") -Devices $("37KPZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait -Verbose
```
Update configuration compliance on all devices in baseline ***This will force a reboot if necessary***
```
Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -Wait -Verbose
```
Update configuration compliance on filtered devices in baseline ***This will force a reboot if necessary***
```
Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait -Verbose
```
Check configuration compliance for baseline
```
$("TestBaseline01" | Get-OMEConfigurationBaseline -FilterBy "Name") | Invoke-OMEConfigurationBaselineRefresh -Wait -Verbose
```

## Profiles
Unassign profile by device
```
Invoke-OMEProfileUnassign -Device $("37KP0ZZ" | Get-OMEDevice) -Wait -Verbose
```
Unassign profile on multiple devices
```
$("37KP0ZZ", "37KT0ZZ" | Get-OMEDevice) | Invoke-OMEProfileUnassign -Wait -Verbose
```
Unassign profile by template
```
Invoke-OMEProfileUnassign -Template $("TestTemplate01" | Get-OMETemplate) -Wait -Verbose
```
Unassign profile by profile name
```
Invoke-OMEProfileUnassign -ProfileName "Profile from template 'TestTemplate01' 00001" -Wait -Verbose
```

## Jobs
List all jobs
```
Get-OMEJob | Format-Table
```
Get job details by Id
```
13852 | Get-OMEJob -Detail -Verbose
```
Get job by job type
```
5 | Get-OMEJob -FilterBy "Type" | Format-Table
```
Get job by last run status
```
2060 | Get-OMEJob -FilterBy "LastRunStatus" | Format-Table
```
Get job by state
```
"Enabled" | Get-OMEJob -FilterBy "State" | Format-Table
```
Export job details to CSV by Id
```
10085 | Get-OMEJob -FilterBy "Id" -Detail | Select-Object  @{Name='JobId'; Expression='Id'}, JobName, JobTypeId, JobType, JobDescription, LastRun -ExpandProperty JobDetail
    | Export-Csv -Path "C:\Temp\OMEJobDetail.csv" -NoTypeInformation
```
Get jobs filter by multiple properties
```
2070 | Get-OMEJob -FilterBy "LastRunStatus" | Where-Object JobTypeId -EQ 101
```
Run job
```
28991 | Invoke-OMEJobRun -Wait -Verbose
```

## Reports
Run report
```
Invoke-Report -ReportId 11709
```

## Alerts
Get 50 most recent critical alerts
```
Get-OMEAlert -SeverityType CRITICAL -Top 50 -Pages 1
```

Get all alert policies
```
Get-OMEAlertPolicy
```

Get alert policy by ID
```
12016 | Get-OMEAlertPolicy
```

Get alert policy by Name (OME API does not currently support filtering by Name natively)
```
Get-OMEAlertPolicy | Where-Object { $_.Name -eq "Group A Alert" }
```

Enable Alert Policy
```
17758 | Get-OMEAlertPolicy | Enable-OMEAlertPolicy
```

Disable Alert Policy
```
17758 | Get-OMEAlertPolicy | Disable-OMEAlertPolicy
```

Disable Multiple Alert Policies
```
$AlertPolicies = Get-OMEAlertPolicy | Where-Object { $_.Name -match "Group A Alert" }
Disable-OMEAlertPolicy -AlertPolicy $AlertPolicies
```

Create alert policy

Use `17758 | Get-OMEAlertPolicy | ConvertTo-Json -Depth 10` to show an existing policy as an example

```
$NewAlertPolicy = '{
    "Name": "Test Alert Policy",
    "Description": null,
    "Enabled": true,
    "DefaultPolicy": false,
    "PolicyData": {
        "Catalogs": [
            {
                "CatalogName": "iDRAC",
                "Categories": [
                    0
                ],
                "SubCategories": [
                    0
                ]
            }
        ],
        "Severities": [
            16
        ],
        "MessageIds": [],
        "Devices": [],
        "DeviceTypes": [],
        "Groups": [
            17745,
            17743,
            17746
        ],
        "AllTargets": false,
        "Schedule": {
            "StartTime": "2023-03-21 04:00:00.017",
            "EndTime": "",
            "CronString": "* * * ? * * *",
            "Interval": false
        },
        "Actions": [
            {
                "Id": 36,
                "Name": "Email",
                "ParameterDetails": [
                    {
                        "Id": 1,
                        "Name": "subject",
                        "Value": "Device Name: $name,  Device IP Address: $ip,  Severity: $severity",
                        "Type": "string",
                        "TypeParams": [
                            {
                                "Name": "maxLength",
                                "Value": "255"
                            }
                        ]
                    },
                    {
                        "Id": 1,
                        "Name": "to",
                        "Value": "support@example.com",
                        "Type": "string",
                        "TypeParams": [
                            {
                                "Name": "maxLength",
                                "Value": "255"
                            }
                        ]
                    },
                    {
                        "Id": 1,
                        "Name": "from",
                        "Value": "ome@example.com",
                        "Type": "string",
                        "TypeParams": [
                            {
                                "Name": "maxLength",
                                "Value": "255"
                            }
                        ]
                    },
                    {
                        "Id": 1,
                        "Name": "message",
                        "Value": "Event occurred for Device Name: $name, Device IP Address: $ip, Identifier: $identifier, UTC Time: $time, Severity: $severity, Message ID: $messageId, $message",
                        "Type": "string",
                        "TypeParams": [
                            {
                                "Name": "maxLength",
                                "Value": "255"
                            }
                        ]
                    }
                ],
                "TemplateId": 50
            }
        ],
        "UndiscoveredTargets": []
    },
    "State": true
}'

New-OMEAlertPolicy -AlertPolicy $NewAlertPolicy
```

## Directory Services 
### Active Directory

Test AD Directory Service using Global Catalog Lookup
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" `
    -DirectoryServerLookup "DNS" -DirectoryServers @("lab.local") -ADGroupDomain "lab.local" `
    -TestConnection -TestUserName "Username@lab.local" -TestPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Verbose
```
Create AD Directory Service using Global Catalog Lookup
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" `
    -DirectoryServerLookup "DNS" -DirectoryServers @("lab.local") -ADGroupDomain "lab.local"
```
Create AD Directory Service using Global Catalog Lookup with Certificate Validation
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" -DirectoryServerLookup "DNS" -DirectoryServers @("lab.local") -ADGroupDomain "lab.local" -CertificateValidation -CertificateFile "C:\Temp\CA.cer"
```
Create AD Directory Service manually specifing Domain Controllers
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "AD" `
    -DirectoryServerLookup "MANUAL" -DirectoryServers @("ad1.lab.local", "ad2.lab.local") -ADGroupDomain "lab.local"
``` 
Import directory group
```
$AD = Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL"
$ADGroups = Get-OMEDirectoryServiceSearch -Name "Admin" -DirectoryService $AD
$Role = Get-OMERole -Name "chassis"
Invoke-OMEDirectoryServiceImportGroup -DirectoryService $AD -DirectoryGroups $ADGroups -DirectoryType "AD" -UserName "Usename@lab.local" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)) -Role $Role -Verbose
```

### LDAP
Create LDAP Directory Service
```
New-OMEDirectoryService -Name "LAB.LOCAL" -DirectoryType "LDAP" `
    -DirectoryServerLookup "MANUAL" -DirectoryServers @("ldap1.lab.local", "ldap2.lab.local") `
    -LDAPBaseDistinguishedName "dc=lab,dc=local"
```

## Backup 
### *Restore must be performed in OME-M at this time*

Backup chassis to CIFS share now
```
$MXChassis = @("LEAD" | Get-OMEMXDomain | Select-Object -First 1)

Invoke-OMEApplianceBackup -Chassis $MXChassis -Share "192.168.1.100" -SharePath "/SHARE" -ShareType "CIFS" `
    -UserName "Administrator" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) `
    -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" `
    -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose
```

Backup chassis to NFS share now
```
$MXChassis = @("LEAD" | Get-OMEMXDomain | Select-Object -First 1)

Invoke-OMEApplianceBackup -Chassis $MXChassis -Share "192.168.1.100" -SharePath "/mnt/data/backup" -ShareType "NFS" `
    -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" `
    -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose
```

Backup chassis to NFS share on schedule every Sunday at 12:00AM UTC
```
$MXChassis = @("LEAD" | Get-OMEMXDomain | Select-Object -First 1)

Invoke-OMEApplianceBackup -Chassis $MXChassis -Share "192.168.1.100" -SharePath "/mnt/data/backup" -ShareType "NFS" `
    -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" -ScheduleCron '0 0 0 ? * sun *' `
    -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose
```

## Services Plugin
Get Support cases for device by Service Tag
```
"C38V9T2" | Get-OMESupportAssistCase -Verbose
```
Export example json used to create new Support Assist group
```
New-OMESupportAssistGroup -ExportExampleJson 
```
Create new Support Assist group from file
```
New-OMESupportAssistGroup -AddGroup $(Get-Content "C:\Temp\Group.json" -Raw) -Verbose
```
Edit Support Assist group
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
Add devices to Support Assist group
```
$devices = $("859N3L3", "759N3L3" | Get-OMEDevice -FilterBy "ServiceTag")
"Support Assist Group 1" | Get-OMEGroup | Edit-OMESupportAssistGroup -Devices $devices -Verbose
```
Remove devices from Support Assist group
```
$devices = $("859N3L3", "759N3L3" | Get-OMEDevice -FilterBy "ServiceTag")
"Support Assist Group 1"  | Get-OMEGroup | Edit-OMESupportAssistGroup -Mode "Remove" -Devices $devices -Verbose
```
Remove Support Assist group
```
"Support Assist Group 1" | Get-OMEGroup | Remove-OMESupportAssistGroup
```
Other Examples
https://github.com/dell/OpenManage-PowerShell-Modules/blob/e8f150a122a16ab458d6cc18298ffe3ce94bf3b2/Examples/ServicesGroupCreateAddDevices.ps1

## MX
### Chassis
Create new Chassis Group
```
New-OMEMcmGroup -Name "TestLabMX"
```
Create new Chassis Group with VIP
```
New-OMEMcmGroup -Name "TestLabMX" -VIPIPv4Address "100.79.6.111" -VIPSubnetMask "255.255.254.0" -VIPGateway "100.79.7.254" -Wait -Verbose 
```

### SmartFabric
Create new Smart Fabric
```
New-OMEFabric -Name "SmartFabric01" -DesignType "2xMX9116n_Fabric_Switching_Engines_in_same_chassis" `
    -SwitchAServiceTag "C38S9T2" -SwitchBServiceTag "CMWSV43" -Verbose
```
Configure Port Breakouts and Refresh Inventory
```
$SwitchA = $("C38S9T2" | Get-OMEDevice)
$SwitchB = $("CMWSV43" | Get-OMEDevice)

Set-OMEIOMPortBreakout -Device $SwitchA -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait -Verbose
Set-OMEIOMPortBreakout -Device $SwitchA -BreakoutType "4X8GFC" -PortGroups "port-group1/1/15,port-group1/1/16" -Wait -Verbose
Set-OMEIOMPortBreakout -Device $SwitchB -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait -Verbose
Set-OMEIOMPortBreakout -Device $SwitchB -BreakoutType "4X8GFC" -PortGroups "port-group1/1/15,port-group1/1/16" -Wait -Verbose
Invoke-OMEInventoryRefresh -Devices @($SwitchA, $SwitchB) -Wait
```
Create new Uplink
```
$SwitchA = $("C38S9T2" | Get-OMEDevice)
$SwitchB = $("CMWSV43" | Get-OMEDevice)
$DefaultNetworks = $("VLAN 1001", "VLAN 1003" | Get-OMENetwork)
$StorageFabricANetwork = $("Storage Fabric A" | Get-OMENetwork)
$StorageFabricBNetwork = $("Storage Fabric B" | Get-OMENetwork)
$Fabric = $("SmartFabric01" | Get-OMEFabric)
New-OMEFabricUplink -Name "EthernetUplink01" -Fabric $Fabric -UplinkType "Ethernet - No Spanning Tree" `
    -TaggedNetworks $DefaultNetworks -Ports "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1" -Verbose
New-OMEFabricUplink -Name "StorageFabricAUplink" -Fabric $Fabric -UplinkType "FC Gateway" `
    -TaggedNetworks $StorageFabricANetwork -Ports "C38S9T2:fibrechannel1/1/43:1" -Verbose
New-OMEFabricUplink -Name "StorageFabricBUplink" -Fabric $Fabric -UplinkType "FC Gateway" `
    -TaggedNetworks $StorageFabricBNetwork -Ports "CMWSV43:fibrechannel1/1/43:1" -Verbose

```
Edit Uplink
```
$Fabric = "SmartFabric01" | Get-OMEFabric
$Uplink = "EthernetUplink01" | Get-OMEFabricUplink -Fabric $Fabric
$AddNetwork = "VLAN 1005", "VLAN 1006" | Get-OMENetwork
$UnTaggedNetwork = "default" | Get-OMENetwork
Edit-OMEFabricUplink -Fabric $Fabric -Uplink $Uplink -Name "NewUplinkName"
Edit-OMEFabricUplink -Fabric $Fabric -Uplink $Uplink -Mode "Append" -TaggedNetworks $AddNetwork -Verbose
Edit-OMEFabricUplink -Fabric $Fabric -Uplink $Uplink -Mode "Append" -Ports "C38S9T2:ethernet1/1/41:2,CMWSV43:ethernet1/1/41:2" -Verbose
Edit-OMEFabricUplink -Fabric $Fabric -Uplink $Uplink -Mode "Remove" -TaggedNetworks $AddNetwork -Ports "C38S9T2:ethernet1/1/41:2" -Verbose
Edit-OMEFabricUplink -Fabric $Fabric -Uplink $Uplink -Mode "Replace" -TaggedNetworks $AddNetwork -Ports "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1" -Verbose
Edit-OMEFabricUplink -Fabric $Fabric -Uplink $Uplink -UnTaggedNetwork $UnTaggedNetwork -Verbose
```

### Templates
Configure Template with Storage Networks
```
$DefaultNetworks = $("VLAN 1001", "VLAN 1003", "VLAN 1004", "VLAN 1005" | Get-OMENetwork)
$StorageFabricANetwork = $("Storage Fabric A" | Get-OMENetwork)
$StorageFabricBNetwork = $("Storage Fabric B" | Get-OMENetwork)
$Template = "MX740c 4 Port" | Get-OMETemplate 
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 1 -TaggedNetworks $DefaultNetworks -Mode "Append" -Verbose
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 2 -TaggedNetworks $DefaultNetworks -Mode "Append" -Verbose
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 1 -TaggedNetworks $StorageFabricANetwork -Mode "Append" -Verbose
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 2 -TaggedNetworks $StorageFabricBNetwork -Mode "Append" -Verbose
```
Remove Network from Template
```
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 1 -TaggedNetworks $StorageFabricANetwork -Mode "Remove" -Verbose
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 2 -TaggedNetworks $StorageFabricBNetwork -Mode "Remove" -Verbose
```
Configure Template Identity Pool
```
$IdentityPool = $("default" | Get-OMEIdentityPool)
"MX740c 4 Port"  | Get-OMETemplate | Set-OMETemplateIdentityPool -IdentityPool $IdentityPool -Verbose
```

## Set Chassis Name
```
$Chassis = "C38V9ZZ" | Get-OMEDevice
Set-OMEChassisName -Name "TESTMX7000-1" -Chassis $Chassis -Wait -Verbose
```

## Set Chassis Slot Names
```
$Chassis = "C38V9ZZ" | Get-OMEDevice
Set-OMEChassisSlotName -Chassis $Chassis -Slot 1 -Name "MX840c-C39N9ZZ" -Wait -Verbose

Set-OMEChassisSlotName -Chassis $Chassis -Slot 1 -Name "MX5108-C38T9ZZ" -SlotType "IOM" -Wait -Verbose
```

## Quick Deploy
```
$RootPassword = $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)
$Chassis = "C38V9ZZ" | Get-OMEDevice
```

Sleds DHCP
```
$QuickDeployDHCP = @(
    @{Slot=1;},
    @{Slot=2;}
)

Invoke-OMEQuickDeploy -RootPassword $RootPassword -SlotType "SLED" -Chassis $Chassis `
    -IPv4Enabled -IPv4NetworkType "DHCP" `
    -Slots $QuickDeployDHCP -Wait -Verbose

Invoke-OMEQuickDeploy -RootPassword $RootPassword -SlotType "SLED" -Chassis $Chassis `
    -IPv4Enabled -IPv4NetworkType "DHCP" `
    -IPv6Enabled -IPv6NetworkType "DHCP" `
    -Slots $QuickDeployDHCP -Wait -Verbose
```

Sleds IPv4 Only
```
$QuickDeployIPv4Static = @(
    @{Slot=1; IPv4Address="192.168.1.100"; VlanId=1}
)
Invoke-OMEQuickDeploy -RootPassword $RootPassword -SlotType "SLED" -Chassis $Chassis `
    -IPv4Enabled -IPv4NetworkType "STATIC" -IPv4SubnetMask "255.255.254.0" -IPv4Gateway "192.168.1.1" `
    -Slots $QuickDeployBothStatic -Verbose
```

Sleds IPv6 Only
```
$QuickDeployIPv6Static = @(
    @{Slot=1; IPv6Address="2001:0db8:85a3:0000:0000:8a2e:0370:7334"; VlanId=1},
    @{Slot=2; IPv6Address="2001:0db8:85a3:0000:0000:8a2e:0370:7335"; VlanId=1}
)
Invoke-OMEQuickDeploy -RootPassword $RootPassword -SlotType "SLED" -Chassis $Chassis `
    -IPv6Enabled -IPv6NetworkType "STATIC" -IPv6Gateway "fe80::1" -IPv6PrefixLength 4 `
    -Slots $QuickDeployIPv6Static -Verbose
```

Sleds IPv4 and IPv6
```
$QuickDeployBothStatic = @(
    @{Slot=1; IPv4Address="192.168.1.100"; IPv6Address="2001:0db8:85a3:0000:0000:8a2e:0370:7334"; VlanId=1}
)
Invoke-OMEQuickDeploy -RootPassword $RootPassword -SlotType "SLED" -Chassis $Chassis `
    -IPv4Enabled -IPv4NetworkType "STATIC" -IPv4SubnetMask "255.255.254.0" -IPv4Gateway "192.168.1.1" `
    -IPv6Enabled -IPv6NetworkType "STATIC" -IPv6Gateway "fe80::1" -IPv6PrefixLength 4 `
    -Slots $QuickDeployBothStatic -Verbose
```

IOM IPv4
```
$QuickDeployIPv4Static = @(
    @{Slot=1; IPv4Address="192.168.1.100"; VlanId=1}
)
Invoke-OMEQuickDeploy -RootPassword $RootPassword -SlotType "IOM" -Chassis $Chassis `
    -IPv4Enabled -IPv4NetworkType "STATIC" -IPv4SubnetMask "255.255.255.0" -IPv4Gateway "192.168.1.1" `
    -Slots $QuickDeployIPv4Static -Verbose
```
## Application Settings
Set Application Settings
```
$Settings = @(
    @{Name="EmailAlertsConf.1#DestinationEmailAddress"; Value="mail.example.net"},
    @{Name="EmailAlertsConf.1#portNumber"; Value=25},
    @{Name="EmailAlertsConf.1#useSSL"; Value=$false},
    @{Name="ChassisLocation.1#DataCenterName"; Value="DC1"},
    @{Name="ChassisLocation.1#RoomName"; Value=""},
    @{Name="ChassisLocation.1#AisleName"; Value=""},
    @{Name="TimeConfig.1#NTPEnable"; Value=$true},
    @{Name="TimeConfig.1#TimeZone"; Value="TZ_ID_9"},
    @{Name="TimeConfig.1#NTPServer1"; Value="0.centos.pool.ntp.org"},
    @{Name="ChassisPower.1#RedundancyPolicy"; Value="GRID_REDUNDANCY"},
    @{Name="ChassisPower.1#EnableHotSpare"; Value=$true},
    @{Name="ChassisPower.1#PrimaryGrid"; Value="GRID_1"},
    @{Name="SessionConfiguration.1#maxSessions"; Value=100},
    @{Name="SSH.1#Enable"; Value=$true},
    @{Name="Preference.1#DeviceName"; Value="HOST_NAME"}
)

Set-OMEApplicationSettings -Settings $Settings -Wait -Verbose
```

Get Application Settings
```
$CurrentSettings = Get-OMEApplicationSettings
$CurrentSettings.SystemConfiguration.Components[0].Attributes | Format-Table
```

## Error Handling and Control Flow
https://devblogs.microsoft.com/scripting/handling-errors-the-powershell-way
```
The -ErrorAction common parameter allows you to specify which action to take if a command fails. The available options are: Stop, Continue, SilentlyContinue, Ignore, or Inquire. By default, Windows PowerShell uses an error action preference of Continue, which means that errors will be written out to the host, but the script will continue to execute.
```

## Troubleshooting
Verbose Output
- Append `-Verbose` to any command

Redirect ALL output to file
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot" *> firmware.txt
```

Get PowerShell Version

`$PSVersionTable`

Get PowerShell Module Path

`$env:PSModulePath`

## Support
This code is provided as-is and currently not officially supported by Dell EMC.

To report problems or provide feedback https://github.com/dell/OpenManage-PowerShell-Modules/issues

## License

Copyright Dell EMC