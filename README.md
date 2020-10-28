# DellOpenManage Powershell Module

# Install Module

## Requirements
- PowerShell 5+
- OpenManage Enterprise 3.3.1+

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
3. List available Modules `Get-Module -ListAvailable -Name "DellOpenManage"`
4. Import module `Import-Module DellOpenManage`

# Command Reference
See [Command Reference](Documentation/CommandReference.md)

# Examples

## Getting Started
See if Module is available
```
Get-Module -ListAvailable -Name "DellOpenManage"
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
New-OMEDiscovery -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait
```
Discover servers by IP Address
```
New-OMEDiscovery -Hosts @('10.35.0.0', '10.35.0.1') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait
```
Discover servers by Subnet
```    
New-OMEDiscovery -Hosts @('10.37.0.0/24') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait
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

## Device Details
Get all inventory
```
10097, 10100 | Get-OMEDevice -FilterBy "Id" | Get-OMEDeviceDetail 
```
Get network cards and mac addresses
```
"C39P9ZZ", "C39N9ZZ" | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "network" | Format-Table
```
Get firmware inventory
```
"C39P9ZZ", "C39N9ZZ" | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "software" | Format-Table
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
"AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -DeviceFilter $devices | Select-Object -Property ServiceTag,DeviceModel,DeviceName,CurrentVersion,Version,UpdateAction,ComplianceStatus,Name | Format-Table
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
Create new template from source device
```
New-OMETemplateFromDevice -Name "TestTemplate" -Device $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait
```
Create new template from source device and capture specific components
```
New-OMETemplateFromDevice -Name "TestTemplate" -Component "iDRAC", "BIOS" -Device $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait
```
Create new template from XML string
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
Create new template from XML file
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

## License

Copyright Dell EMC