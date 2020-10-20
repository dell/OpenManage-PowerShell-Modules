function Get-PowerShellVersion {
    $get_host_info = Get-Host
    [int]$major_number = $get_host_info.Version.Major
    return $major_number
}
$MajorVersion = Get-PowerShellVersion
if ($MajorVersion -lt 5) {
    Write-Error "PowerShell Version 5 or later required"
    exit
} else {
    $Source = "DellOpenManage"
    $Destination = "$home\Documents\WindowsPowerShell\Modules"
    if (Test-Path -Path $Destination) {
        Try {
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force -ErrorAction Stop
            Write-Output "Sucessfully installed OpenManage Module to $Destination"
        }
        Catch {
            Write-Error ($_.Exception | Format-List -Force | Out-String)
            Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
        }
    }
}
