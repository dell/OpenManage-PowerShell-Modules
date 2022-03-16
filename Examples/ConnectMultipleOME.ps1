$OMEUsername = "admin"
$OMEPassword = "calvin"
$OMEServers = @("ome01.example.com", "ome02.example.com", "ome03.example.com")
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)

foreach ($OMEServer in $OMEServers) {
    Write-Host "Connecting to $($OMEServer)"
    Connect-OMEServer -Name $OMEServer -Credentials $Credentials -IgnoreCertificateWarning -ErrorAction SilentlyContinue
    Get-OMEDevice | Format-Table
    Disconnect-OMEServer
}