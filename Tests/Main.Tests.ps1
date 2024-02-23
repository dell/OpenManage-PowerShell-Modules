[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String]$Test,

    [Parameter(Mandatory=$false)]
    [String[]]$Tag,

    [Parameter(Mandatory=$false)]
    [String]$Server
)

. .\Credentials.ps1
& .\Install-Module.ps1


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
$Global:SSHUsername = $SSHUsername
$Global:SSHPassword = $SSHPassword

$PesterPreference = [PesterConfiguration]::Default
$PesterPreference.Output.Verbosity = 'Detailed'

if ($Test -ne "") {
    if ($Tag -ne "") {
        Invoke-Pester ".\Tests\$($Test).Tests.ps1" -Tag $Tag
    } else {
        Invoke-Pester ".\Tests\$($Test).Tests.ps1"
    }
} else {
    Invoke-Pester .\Tests\Discovery.Tests.ps1
    Invoke-Pester .\Tests\Device.Tests.ps1
    Invoke-Pester .\Tests\Group.Tests.ps1
    Invoke-Pester .\Tests\Firmware.Tests.ps1
    Invoke-Pester .\Tests\Template.Tests.ps1
    Invoke-Pester .\Tests\User.Tests.ps1
    Invoke-Pester .\Tests\SupportAssist.Tests.ps1
}
