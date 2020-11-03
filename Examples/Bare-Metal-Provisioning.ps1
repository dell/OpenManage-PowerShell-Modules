
#Requires -Modules DellOpenManage

# Import Module
Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

# Get Devices
$devices = $("C39NZZZ" | Get-OMEDevice -FilterBy "ServiceTag")

# Update Firmware
Update-OMEFirmware -Baseline $("Latest Validated Baseline" | Get-OMEFirmwareBaseline) -DeviceFilter $devices -UpdateSchedule "Preview" -Wait
$confirmation = Read-Host "Do you want to proceed with the update?"
if ($confirmation -eq 'y') {
    Update-OMEFirmware -Baseline $("Latest Validated Baseline" | Get-OMEFirmwareBaseline) -DeviceFilter $devices -UpdateSchedule "StageForNextReboot" -Wait
}

# Apply Template and Install OS
"mx840c Virtual Identities" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $devices -ForceHostReboot -NetworkBootShareType "NFS"`
    -NetworkBootShareIpAddress $NFSServer -NetworkBootIsoPath $NFSISOPath -Wait

Disconnect-OMEServer