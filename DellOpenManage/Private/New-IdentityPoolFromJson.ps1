using module ..\Classes\IdentityPool.psm1
function New-IdentityPoolFromJson {
    Param(
        [PSCustomObject]$IdentityPool
    )
    if ($Device.LastUpdateTime -eq "null") {
        $Device.LastUpdateTime = $null
    }
    if ($Device.CreationTime -eq "null") {
        $Device.CreationTime = $null
    }
    $IdentityPoolObj = [IdentityPool]@{
        Id = $IdentityPool.Id
        Name = $IdentityPool.Name
        Description = $IdentityPool.Description
        CreatedBy = $IdentityPool.CreatedBy
        CreationTime = $IdentityPool.CreationTime
        LastUpdatedBy = $IdentityPool.LastUpdatedBy
        LastUpdateTime = $IdentityPool.LastUpdateTime
        EthernetSettings = $IdentityPool.EthernetSettings
        IscsiSettings = $IdentityPool.IscsiSettings
        FcoeSettings = $IdentityPool.FcoeSettings
        FcSettings = $IdentityPool.FcSettings
    }
    return $IdentityPoolObj
}

