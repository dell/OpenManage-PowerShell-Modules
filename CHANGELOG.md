Release 1.0.0 - 11/10/2020
* Added Get-OMEDeviceNetworkDetail to show IP and Mac Address for quick export
* Modified Get-OMEDeviceDetail and removed the mapping for InventoryType. Specify the actual value instead of an abbreviated version

Release 2.0.0 - 5/3/2021
* Bumped minimum required OpenManage Enterprise version to 3.4
* Edit-OMEDiscovery new module to edit discovery jobs
* New-OMEDiscovery added ability to schedule job at a later date, added support for REDFISH discovery protocol
* New-OMEFirmwareBaseline refactored -Wait to  poll the completion status instead of a predefined sleep
* Get-OMEFirmwareCompliance modified -UpdateAction "All" to include components that have versions equal to that of the baseline

Release 2.1.0 5/13/2021
* New-OMEConfigurationBaseline new commandlet
* New-OMETemplateFromDevice updated to support creation of Configuration templates
* New-OMETemplateFromFile updated to support creation of Configuration templates
* Get-OMEConfigurationBaseline new commandlet
* Get-OMETemplate added ability to get Deployment or Configuration templates
* Get-OMEConfigurationCompliance new commandlet
* Update-OMEConfiguration new commandlet
* Invoke-OMEProfileUnassign new commandlet
* Invoke-OMEConfigurationBaselineRefresh new commandlet

Release 2.2.0 6/24/2021
* OME 3.6.1 testing completed
* New-OMEGroup new commandlet
* Edit-OMEGroup new commandlet
* Remove-OMEGroup new commandlet
* Invoke-OMEInventoryRefresh new commandlet

Release 2.2.1 6/25/2021
* Invoke-OMEJobRun new commandlet
* Invoke-OMEFirmwareBaselineRefresh new commandlet
* Invoke-OMEConfigurationCheck renamed to Invoke-OMEConfigurationBaselineRefresh

Release 2.2.2 6/25/2021
* Invoke-OMEInventoryRefresh added -Wait parameter

Release 2.3.0
* Fixed Set-CertPolicy to allow multiple Connect-OME within script (Issue #2)
* Fixed Set-OMEPowerState (Issue #3)
* Migrated scripts from https://github.com/dell/OpenManage-Enterprise/tree/master/PowerShell
* New commandlets
    * Get-OMEAuditLogs
    * Get-OMEWarranty
    * Get-OMEAlerts
    * Get-OMEUser
    * New-OMEUser
    * Get-OMEIdentityPool
    * Get-OMEIdentityPoolUsage
    * New-OMEIdentityPool
    * New-OMENetwork
    * Get-OMENetwork
    * Update-OMEFirmwareDUP
    * Edit-OMESecurityBanner
    * New-OMESupportAssistGroup
    * Get-OMESupportAssistGroup
    * Edit-OMESupportAssistGroup
    * Remove-OMESupportAssistGroup
    * Get-OMESupportAssistCases
    * New-OMEMcmGroup
    * Invoke-OMEMcmGroupAddMember
    * Invoke-OMEMcmGroupAssignBackupLead
    * Invoke-OMEMcmGroupRetireLead
    * Get-OMEMXDomains