using module ..\Classes\NetworkPartition.psm1
function New-NetworkPartitionFromJson {
    Param(
        [PSCustomObject]$NetworkPartition
    )
    $Model = $NetworkPartition.ProductName.Substring(0,$NetworkPartition.ProductName.IndexOf("-"))
    $Model = $Model.Trim()
    return [NetworkPartition]@{
        DeviceId = $NetworkPartition.DeviceId
        DeviceName = $NetworkPartition.DeviceName
        DeviceServiceTag = $NetworkPartition.DeviceServiceTag
        NicId = $NetworkPartition.NicId
        VendorName = $NetworkPartition.VendorName
        PortId = $NetworkPartition.PortId
        Model = $Model
        LinkStatus = $NetworkPartition.LinkStatus
        LinkSpeed = $NetworkPartition.LinkSpeed
        Fqdd = $NetworkPartition.Fqdd
        CurrentMacAddress = $NetworkPartition.CurrentMacAddress
        PermanentMacAddress = $NetworkPartition.PermanentMacAddress
        PermanentFcoeMacAddress = $NetworkPartition.PermanentFcoeMacAddress
        VirtualMacAddress = $NetworkPartition.VirtualMacAddress
        VirtualIscsiMacAddress = $NetworkPartition.VirtualIscsiMacAddress
        VirtualFipMacAddress = $NetworkPartition.VirtualFipMacAddress
        NicMode = $NetworkPartition.NicMode
        FcoeMode = $NetworkPartition.FcoeMode
        IscsiMode = $NetworkPartition.IscsiMode
        MinBandwidth = $NetworkPartition.MinBandwidth
        MaxBandwidth = $NetworkPartition.MaxBandwidth
    }
}