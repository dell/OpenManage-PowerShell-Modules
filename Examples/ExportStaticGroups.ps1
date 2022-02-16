$StaticGroupId = "Static Groups" | Get-OMEGroup | Select-Object -ExpandProperty Id
$StaticGroups = Get-OMEGroup | Where-Object "ParentId" -eq $StaticGroupId
[PSCustomObject]$GroupTable = @()
$StaticGroups | ForEach-Object { 
    $Group = $_
    $Devices = $Group | Get-OMEDevice
    $Devices | ForEach-Object {
        $Device = $_
        $GroupTable += [PSCustomObject]@{
            GroupName = $Group.Name
            Device = $Device.Identifier 
        }
    }
}
$GroupTable | Format-Table
$GroupTable | Export-Csv -Path "C:\Temp\Groups.csv" -NoTypeInformation

Import-CSV "C:\Temp\Groups.csv" | Foreach-Object {
    $GroupName = $_.GroupName
    $DeviceIdentifier = $_.Device
    $Group = $($GroupName | Get-OMEGroup)
    # Create static group if not found
    if (-not $Group) {
        New-OMEGroup $GroupName
        $Group = $($GroupName | Get-OMEGroup)
    }

    # Add devices to groups
    Write-Host "Adding device $($DeviceIdentifier) to group $($GroupName)"
    $Group | Edit-OMEGroup -Devices $($DeviceIdentifier | Get-OMEDevice -FilterBy "ServiceTag")
}