[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String]$Test,

    [Parameter(Mandatory=$false)]
    [String]$Server
)

. .\Credentials.ps1

# Requires Pester 4.0+
#Install-Module -Name Pester -Scope CurrentUser -Force
Import-Module Pester
Remove-Module DellOpenManage
Import-Module DellOpenManage

if ($Server) {
    $Global:OMEServer = $Server
} else {
    $Global:OMEServer = $OMEServer
}
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
    Invoke-Pester -Script .\Tests\Configuration.Tests.ps1
}



#Invoke-Pester -Script @{Path='.\Tests\Device.Tests.ps1'}

#Invoke-Pester -Script @{ Path = 'Device.Tests.ps1'; Parameters = @{ NamedParameter = 'Passed By Name' }; Arguments = @('Passed by position') }
#Invoke-Pester -Script D:\MyModule, @{ Path = '.\Tests\Utility\ModuleUnit.Tests.ps1'; Parameters = @{ Name = 'User01' }; Arguments = srvNano16  }
