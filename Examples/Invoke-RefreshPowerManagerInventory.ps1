# Script to run default inventory task to determine power management capabilities of devices post OMEnt-Power Manager Installation

#Requires -Modules DellOpenManage

Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

$DefaultInventoryJob = Get-OMEJob | Where-Object { $_.JobName -eq 'Default Inventory Task' }
$DefaultInventoryJob.Id | Invoke-OMEJobRun -Wait

Disconnect-OMEServer