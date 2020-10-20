[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String]$Test
)

. .\Credentials.ps1

Remove-Module DellOpenManage
Import-Module DellOpenManage

$Global:OMEServer = $OMEServer
$Global:OMEUsername = $OMEUsername
$Global:OMEPassword = $OMEPassword
$Global:iDRACUsername = $iDRACUsername
$Global:iDRACPassword = $iDRACPassword

if ($Test -ne "") {
    Invoke-Pester -Script ".\Tests\$($Test).Tests.ps1"
} else {
    Invoke-Pester -Script .\Tests\Device.Tests.ps1
    Invoke-Pester -Script .\Tests\Firmware.Tests.ps1
    Invoke-Pester -Script .\Tests\Template.Tests.ps1
}



#Invoke-Pester -Script @{Path='.\Tests\Device.Tests.ps1'}

#Invoke-Pester -Script @{ Path = 'Device.Tests.ps1'; Parameters = @{ NamedParameter = 'Passed By Name' }; Arguments = @('Passed by position') }
#Invoke-Pester -Script D:\MyModule, @{ Path = '.\Tests\Utility\ModuleUnit.Tests.ps1'; Parameters = @{ Name = 'User01' }; Arguments = srvNano16  }
