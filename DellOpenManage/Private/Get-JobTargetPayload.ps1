<#
.SYNOPSIS
Generate JSON object to be used when submitting Jobs to the JobService

.DESCRIPTION

.PARAMETER $Targets
Int[] containing DeviceId each device to be targetd in job

.OUTPUTS
PCCustomObject
#>
function Get-JobTargetPayload($Targets) {
    $TargetTypeHash = @{}
    $TargetTypeHash.'Id' = 1000
    $TargetTypeHash.'Name' = "DEVICE"
    $TargetList = @()
    foreach ($Target in $Targets) {
        $TargetHash = @{}
        $TargetHash.TargetType = $TargetTypeHash
        $TargetHash.Id = $Target
        $TargetList += $TargetHash
    }
    return ,$TargetList # Preceeding comma is a workaround to ensure an array is returned when only a single item is present
}