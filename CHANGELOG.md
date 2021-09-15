# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.1]() - 2021-09-14
### Added
- Migrated scripts from https://github.com/dell/OpenManage-Enterprise/tree/master/PowerShell
- Get-OMEAuditLog 
- Get-OMEWarranty
- Get-OMEAlert
- Get-OMEUser
- New-OMEUser
- Get-OMEIdentityPool
- Get-OMEIdentityPoolUsage
- New-OMEIdentityPool
- New-OMENetwork
- Get-OMENetwork
- Update-OMEFirmwareDUP
- Edit-OMESecurityBanner
- New-OMESupportAssistGroup
- Get-OMESupportAssistGroup
- Edit-OMESupportAssistGroup
- Remove-OMESupportAssistGroup
- Get-OMESupportAssistCase
- New-OMEMcmGroup
- Invoke-OMEMcmGroupAddMember
- Invoke-OMEMcmGroupAssignBackupLead
- Invoke-OMEMcmGroupRetireLead
- Get-OMEMXDomain

### Changed
- Changed Invoke-OMETemplateDeploy to use SecureString for -NetworkBootSharePassword
- Added -UseAllProtocols parameter to New-OMEDiscovery ([Issue #4](https://github.com/dell/OpenManage-PowerShell-Modules/issues/4))

### Fixed
- Fixed Set-CertPolicy to allow multiple Connect-OME within script ([Issue #2](https://github.com/dell/OpenManage-PowerShell-Modules/issues/2))
- Fixed Set-OMEPowerState ([Issue #3](https://github.com/dell/OpenManage-PowerShell-Modules/issues/3))

## [2.2.2]() - 2021-06-25
### Fixed
- Invoke-OMEInventoryRefresh added -Wait parameter

## [2.2.1]() - 2021-06-25
### Added
- Invoke-OMEJobRun new commandlet
- Invoke-OMEFirmwareBaselineRefresh new commandlet
- Invoke-OMEConfigurationCheck renamed to Invoke-OMEConfigurationBaselineRefresh

## [2.2.0]() - 2021-06-24
### Added
- OME 3.6.1 testing completed
- New-OMEGroup new commandlet
- Edit-OMEGroup new commandlet
- Remove-OMEGroup new commandlet
- Invoke-OMEInventoryRefresh new commandlet

## [2.1.0]() - 2021-05-13
### Added
- New-OMEConfigurationBaseline new commandlet
- Get-OMEConfigurationBaseline new commandlet
- Get-OMEConfigurationCompliance new commandlet
- Update-OMEConfiguration new commandlet
- Invoke-OMEProfileUnassign new commandlet
- Invoke-OMEConfigurationBaselineRefresh new commandlet

### Fixed
- New-OMETemplateFromDevice updated to support creation of Configuration templates
- New-OMETemplateFromFile updated to support creation of Configuration templates
- Get-OMETemplate added ability to get Deployment or Configuration templates

## [2.0.0]() - 2021-05-03
### Fixed
- Bumped minimum required OpenManage Enterprise version to 3.4
- Edit-OMEDiscovery new module to edit discovery jobs
- New-OMEDiscovery added ability to schedule job at a later date, added support for REDFISH discovery protocol
- New-OMEFirmwareBaseline refactored -Wait to  poll the completion status instead of a predefined sleep
- Get-OMEFirmwareCompliance modified -UpdateAction "All" to include components that have versions equal to that of the baseline

## [1.0.0]() - 2020-11-10
### Fixed
- Added Get-OMEDeviceNetworkDetail to show IP and Mac Address for quick export
- Modified Get-OMEDeviceDetail and removed the mapping for InventoryType. Specify the actual value instead of an abbreviated version

