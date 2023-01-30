Class Uplink {
    [String]$Id
    [String]$Name
    [String]$Description
    [String]$MediaType
    [Int]$NativeVLAN
    [Int]$PortCount
    [Int]$NetworkCount
    [String]$UfdEnable
    [String[]]$Ports=@()
    [String[]]$Networks=@()
}