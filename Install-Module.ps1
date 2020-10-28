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
    $ModuleDir = "\DellOpenManage"
    $Source = $PSScriptRoot + $ModuleDir
    if ($MajorVersion -ge 6) {
        $Destination = "$home\Documents\PowerShell\Modules"
    } else {
        $Destination = "$home\Documents\WindowsPowerShell\Modules"
    }
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force
    }
    if ((Test-Path -Path $Destination) -and (Test-Path -Path $Source)) {
        Try {
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force -ErrorAction Stop
            Get-ChildItem ($Destination + $ModuleDir) -Recurse | Unblock-File
            Write-Output "Sucessfully installed OpenManage Module to $Destination"
        }
        Catch {
            Write-Error ($_.Exception | Format-List -Force | Out-String)
            Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
        }
    }
}
