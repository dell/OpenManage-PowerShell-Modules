using module ..\..\Classes\Device.psm1
function Get-OMEDeviceDetail() {
<#
Copyright (c) 2018 Dell EMC Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

<#
.SYNOPSIS
    Get device inventory from OpenManage Enterprise
.DESCRIPTION
    Returns device inventory. Can be filtered by InventoryType. 
    Requires a Device object to be passed in from Get-OMEDevice
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function. 
.PARAMETER InventoryType
    String to specify the inventory section to return (deviceCapabilities,serverDeviceCards,chassisControllerList,chassisFansList,chassisPciDeviceList,chassisPowerSupplies,chassisSlotsList,chassisStorageComputeAssociations,chassisTemperatureList,serverRaidControllers,serverProcessors,serverArrayDisks,serverFcCards,serverVirtualFlashes,deviceFru,deviceLicense,deviceLocation,deviceManagement,serverMemoryDevices,serverNetworkInterfaces,serverOperatingSystems,serverSupportedPowerStates,serverPowerSupplies,deviceSoftware,serverStorageEnclosures,subsystemRollupStatus)
    These are device specific. A full list can be found by querying the OME API at /api/DeviceService/Devices(DeviceId)/InventoryTypes
.INPUTS
    Device[]
.EXAMPLE
    "C86F000", "3XMHHHH" | Get-OMEDevice -FilterBy "ServiceTag" | Get-OMEDeviceDetail

    Get all inventory for devices
.EXAMPLE
    "C86F000", "3XMHHHH" | Get-OMEDevice -FilterBy "ServiceTag" | Get-OMEDeviceDetail -InventoryType "deviceSoftware"
    
    Get software inventory for devices
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Device[]]$Devices,
    [Parameter(Mandatory=$false)]
    [String]$InventoryType = ""
)
Begin {
    if(!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        Break
        Return
    }

}
Process {
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        if ($Id) {
            $Id = $Id
        } else {
            $Id = $Devices.Id
        }
        $InventoryUrl = $BaseUri + "/api/DeviceService/Devices($($Devices.Id))/InventoryDetails"
        if($InventoryType -ne ""){
            $InventoryUrl =  $BaseUri + "/api/DeviceService/Devices($($Devices.Id))/InventoryDetails('$($InventoryType)')"
        }
        $InventoryResp = Invoke-WebRequest -Uri $InventoryUrl -UseBasicParsing -Headers $Headers -Method Get -ContentType $Type
        if ($InventoryResp.StatusCode -eq 200) {
            $InventoryInfo = $InventoryResp.Content | ConvertFrom-Json
            if ($InventoryInfo.'value') {
                $InventoryData = $InventoryInfo.'value'
            } else {
                $InventoryData = $InventoryInfo
            }
            $InventoryDetails = @()
            foreach ($InventoryDetail in $InventoryData) {
                $InventoryInfo = @{
                    DeviceId = $Devices.Id
                    DeviceName = $Devices.DeviceName
                    DeviceServiceTag = $Devices.DeviceServiceTag
                    InventoryType = $InventoryDetail.InventoryType
                    InventoryInfo = $InventoryDetail.InventoryInfo
                }
                $InventoryDetails += New-InventoryDetailFromJson $InventoryInfo
            }
            return $InventoryDetails
        }
        elseif($InventoryResp.StatusCode -eq 400){
            Write-Warning "Inventory type $($InventoryType) not applicable for device id $($Id) "
        }
        else {
            Write-Warning "Unable to retrieve inventory for device $($Id) due to status code ($($InventoryResp.StatusCode))"
        }
    }
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}