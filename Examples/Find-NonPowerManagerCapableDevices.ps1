# Script to get the list of devices which are not capable of power policy capping with OMEnt-Power Manager

#Requires -Modules DellOpenManage

Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

# If device type is server, check for both power monitoring bit 1006 and power capping bit 1105
Get-OMEDevice | Where-Object `
    { $_.Type -eq 1000 -and { $_.DeviceCapabilities -notcontains  1105 -or  $_.DeviceCapabilities -notcontains  1006 } }`
    | Format-Table

# If device type is chassis, check only for power capping bit 1105
Get-OMEDevice | Where-Object `
    { $_.Type -eq 2000 -and $_.DeviceCapabilities -notcontains  1105 }`
    | Format-Table

Disconnect-OMEServer