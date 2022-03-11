$GroupName = "TestGroup01"
$Hosts = @("server01-idrac.example.com", "server02-idrac.example.com")

New-OMEDiscovery -Name "TestDiscovery01" -Hosts $Hosts -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
$Group = $($GroupName | Get-OMEGroup)
# Create static group if not found
if (-not $Group) {
    New-OMEGroup $GroupName
    $Group = $($GroupName | Get-OMEGroup)
}
# Loop through hosts and add to group by iDRAC DNS name
$Hosts | Foreach-Object {
    $Hostname = $_
    $Group | Edit-OMEGroup -Devices $($Hostname | Get-OMEDevice -FilterBy "Name")
}