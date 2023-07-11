$AllDevices = Get-OMEDevice # Get all devices and store in variable
$HostIPs = Get-Content "C:\Temp\hosts.txt" # Get context of text file
$NewDevices = @() # Variable to hold devices found by IP
foreach ($ip in $HostIPs) { # Loop through text file contents
    $IPMatch = $AllDevices | Where-Object {$_.NetworkAddress -EQ $ip} # Look for device with matching IP
    if ($IPMatch.Count -gt 0) { # Match found
        $DeviceMatch = $IPMatch.Identifier | Get-OMEDevice -FilterBy "ServiceTag" # Get Device object by Service Tag
        $NewDevices += $DeviceMatch # Add Device to array
    }
}
Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Devices $NewDevices # Edit group and add devices from the array we created