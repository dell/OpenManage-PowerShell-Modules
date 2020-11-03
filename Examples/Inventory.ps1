
#Requires -Modules DellOpenManage

Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

# Get all devices of type server
$Devices = $("C39NZZZ" | Get-OMEDevice -FilterBy "ServiceTag")

$Devices | Get-OMEDeviceDetail -InventoryType "cards" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "cpus" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "network" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Select-Object -Property DeviceName,DeviceServiceTag,NicId,VendorName -ExpandProperty Ports |
    Select-Object -Property DeviceName,DeviceServiceTag,NicId,VendorName,PortId,ProductName -ExpandProperty Partitions |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "fc" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "os" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "flash" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "psu" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "disks" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "controllers" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Select-Object -Property DeviceName,DeviceServiceTag,Name,Status,PciSlot,ServerVirtualDisks |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "memory" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "storage" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "powerstates" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "license" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Select-Object -Property DeviceName,DeviceServiceTag,LicenseDescription,EntitlementId -ExpandProperty LicenseType |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "capabilities" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "fru" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "management" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "software" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "location" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List
$Devices | Get-OMEDeviceDetail -InventoryType "subsystem" |
    Select-Object -Property DeviceName,DeviceServiceTag -ExpandProperty InventoryInfo |
    Format-List

Disconnect-OMEServer