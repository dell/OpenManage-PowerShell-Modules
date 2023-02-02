using module ..\Classes\Uplink.psm1
function New-UplinkFromJson {
    Param(
        [PSCustomObject]$Uplink,
        [String[]]$Ports,
        [Int[]]$Networks
    )
    return [Uplink]@{
        Id = $Uplink.Id
        Name = $Uplink.Name
        Description = $Uplink.Description
        MediaType = $Uplink.MediaType
        NativeVLAN = $Uplink.NativeVLAN
        PortCount = $Uplink.Summary.PortCount
        NetworkCount = $Uplink.Summary.NetworkCount
        UfdEnable = $Uplink.UfdEnable
        Ports = $Ports
        Networks = $Networks
    }
}