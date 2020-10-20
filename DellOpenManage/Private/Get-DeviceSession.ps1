function Get-DeviceSession {
    Param(
        [String]$Name
    )
    foreach ($Session in $Script:DeviceSessionAuth) {
        if ($Session.Host -eq $Name) {
            return $Session
        }
    }
}