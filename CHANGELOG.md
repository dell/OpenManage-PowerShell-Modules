11/10/2020
* Added Get-OMEDeviceNetworkDetail to show IP and Mac Address for quick export
* Modified Get-OMEDeviceDetail and removed the mapping for InventoryType. Specify the actual value instead of an abbreviated version

5/3/2021
* Edit-OMEDiscovery new module to edit discovery jobs
* New-OMEDiscovery added ability to schedule job at a later date, added support for REDFISH discovery protocol
* New-OMEFirmwareBaseline refactored -Wait to actually poll the status instead of a predefined sleep
* Get-OMEFirmwareCompliance modified -UpdateAction "All" to include components that have versions equal to that of the baseline