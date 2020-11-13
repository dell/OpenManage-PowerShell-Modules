using module ..\Classes\NetworkPartition.psm1
function New-NetworkPartitionFromJson {
    Param(
        [PSCustomObject]$NetworkPartition
    )
    if ($NetworkPartition.ProductName) {
        if ($NetworkPartition.ProductName.IndexOf("-") -ge 0) {
            $Model = $NetworkPartition.ProductName.Substring(0,$NetworkPartition.ProductName.IndexOf("-"))
        } else {
            $Model = $NetworkPartition.ProductName
        }
        $Model = $Model.Trim()
    }
    return [NetworkPartition]@{
        DeviceId = $NetworkPartition.DeviceId
        DeviceName = $NetworkPartition.DeviceName
        DeviceServiceTag = $NetworkPartition.DeviceServiceTag
        ManagementIpAddress = $NetworkPartition.ManagementIpAddress
        ManagementMacAddress = $NetworkPartition.ManagementMacAddress
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