# DellOpenManage Powershell Module

# Install Module

## Requirements
- PowerShell 5+
- OpenManage Enterprise 3.4+

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

Integration tests will be performed against all pull requests before merging

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


# Command Reference
See [Command Reference](Documentation/CommandReference.md)

# Examples

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
## Basic Example
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
Run job
```
28991 | Invoke-OMEJobRun -Wait -Verbose
```

## Reports
Run report
```
Invoke-Report -ReportId 11709
```

## Troubleshooting
Verbose Output
- Append `-Verbose` to any command

Redirect ALL output to file
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot" *> firmware.txt
```

## Support
This code is provided as-is and currently not officially supported by Dell EMC.

To report problems or provide feedback https://github.com/dell/OpenManage-PowerShell-Modules/issues

## License

Copyright Dell EMC