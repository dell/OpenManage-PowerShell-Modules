using module ..\Classes\Device.psm1
function New-DeviceFromJson {
    Param(
        [PSCustomObject]$Device
    )

    if ($Device.LastInventoryTime -eq "null") {
        $Device.LastInventoryTime = $null
    }


    $DnsName = ""
    $NetworkAddress = ""
    $MacAddress = ""
    # We only want the iDRAC network attributes
    foreach ($DeviceManagement in $Device.DeviceManagement) {
        foreach ($ManagementProfile in $DeviceManagement.ManagementProfile) {
            if ($ManagementProfile.AgentName -eq "iDRAC" -and $DeviceManagement.NetworkAddress -ne "[::]") {
                $DnsName = $DeviceManagement.DnsName
                $NetworkAddress = $DeviceManagement.NetworkAddress
                $MacAddress = $DeviceManagement.MacAddress
                break
            }
        }
    }

    return [Device]@{
        Id = $Device.Id
        Identifier = $Device.Identifier
        DeviceServiceTag = $Device.DeviceServiceTag
        ChassisServiceTag = $Device.ChassisServiceTag
        Model = $Device.Model
        Type = $Device.Type
        PowerState = $Device.PowerState
        ManagedState = $Device.ManagedState
        ConnectionState = $Device.ConnectionState
        Status = $Device.Status
        AssetTag = $Device.AssetTag
        DeviceName = $Device.DeviceName
        LastInventoryTime = $Device.LastInventoryTime
        LastStatusTime = $Device.LastStatusTime
        DnsName = $DnsName
        NetworkAddress = $NetworkAddress
        MacAddress = $MacAddress
        DeviceCapabilities = $Device.DeviceCapabilities
    }
}