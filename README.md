# DellOpenManage Powershell Module

# Install Module

## Requirements
- PowerShell 5+
- OpenManage Enterprise 3.3.1+

## Scripted Installation
1. Open PowerShell Command Window
2. CD to the directory where you cloned the Github repo
3. .\Install-Module.ps1

## Manual Installation
1. Determine module path `$Env:PSModulePath` 
    * Example: C:\Users\username\Documents\WindowsPowerShell\Modules
2. Copy the DellOpenManage folder to a directory in your module path 
    * Example: C:\Users\username\Documents\WindowsPowerShell\Modules\DellOpenManage
3. Import module `Import-Module DellOpenManage`

# Examples

## Module Function and Type Definitions
See [Command Reference](Documentation/CommandReference.md)

## Quick Start
```
Import-Module DellOpenManage
Connect-OMEServer -Name "ome.example.com" -Credentials $(Get-Credential) -IgnoreCertificateWarning
"PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Format-Table
Disconnect-OMEServer
```

## Import Module
```
Import-Module DellOpenManage
```

## Connect
Connect
```
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admin", $(ConvertTo-SecureString -Force -AsPlainText "password")
Connect-OMEServer -Name "ome.example.com" -Credentials $credentials 
```
Connect: Prompt for Credentials
```
$credentials = Get-Credential
Connect-OMEServer -Name "ome.example.com" -Credentials $credentials 
```
Disconnect
```
Disconnect-OMEServer
```

## Devices
Get device by id
```
10097, 10100 | Get-OMEDevice | Format-Table
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
Get inventory section
```
"C39P9ZZ", "C39N9ZZ" | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "network" 
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
Update-OMEFirmware -Baseline $baseline -UpdateSchedule "RebootNow" | Format-Table
```
Update firmware on all devices in baseline on next reboot
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot" 
```
Update firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow"
```
Downgrade firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86CZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow" -UpdateAction 
```
Update firmware on specific components in baseline on next reboot and clear job queue
```
Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -ComponentFilter "iDRAC" -UpdateSchedule "StageForNextReboot" -ClearJobQueue 
```

## Templates
Create new template from source device
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