

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Version
)

Update-ModuleManifest -Path ".\DellOpenManage\DellOpenManage.psd1" -ModuleVersion $Version -Copyright "(c) 2025 Dell EMC. All rights reserved."