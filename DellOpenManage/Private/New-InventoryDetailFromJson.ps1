using module ..\Classes\InventoryDetail.psm1
function New-InventoryDetailFromJson {
    Param(
        [PSCustomObject]$InventoryDetail
    )
    return [InventoryDetail]@{
        DeviceId = $InventoryDetail.DeviceId
        DeviceName = $InventoryDetail.DeviceName
        DeviceServiceTag = $InventoryDetail.DeviceServiceTag
        InventoryType = $InventoryDetail.InventoryType
        InventoryInfo = $InventoryDetail.InventoryInfo
    }
}