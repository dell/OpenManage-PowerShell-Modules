using module ..\Classes\Network.psm1
function New-NetworkFromJson {
    Param(
        [PSCustomObject]$Network
    )
    $NetworkObj = [Network]@{
        Id = $Network.Id
        Name = $Network.Name
        Description = $Network.Description
        VlanMaximum = $Network.VlanMaximum
        VlanMinimum = $Network.VlanMinimum
        Type = $Network.Type
    }
    return $NetworkObj
}

