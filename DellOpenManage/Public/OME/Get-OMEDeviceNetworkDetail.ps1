using module ..\..\Classes\Device.psm1
function Get-OMEDeviceNetworkDetail() {
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
.PARAMETER Device
    Array of type Device returned from Get-OMEDevice function. 
.INPUTS
    Device[]
.EXAMPLE
    "C86F000", "3XMHHHH" | Get-OMEDevice -FilterBy "ServiceTag" | Get-OMEDeviceNetworkDetail
    Get network device detail
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Device[]]$Devices
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
        $ExportDeviceData = @()
        $InventoryDetails = $Devices | Get-OMEDeviceDetail
        $DeviceManagment = $InventoryDetails | Where-Object InventoryType -EQ "deviceManagement"
        $NetworkInterfaces = $InventoryDetails | Where-Object InventoryType -EQ "serverNetworkInterfaces"
        foreach ($NetworkCard in $NetworkInterfaces.InventoryInfo) {
            foreach ($NetworkPort in $NetworkCard.Ports) {
                foreach ($NetworkPartition in $NetworkPort.Partitions) {
                    $NetworkPortInfo = @{
                        DeviceId = $Devices.Id
                        DeviceName = $Devices.DeviceName
                        DeviceServiceTag = $Devices.DeviceServiceTag
                        iDRACMacAddress = $DeviceManagment.InventoryInfo[0].MacAddress
                        NicId = $NetworkCard.NicId
                        VendorName = $NetworkCard.VendorName
                        PortId = $NetworkPort.PortId
                        ProductName = $NetworkPort.ProductName
                        LinkStatus = $NetworkPort.LinkStatus
                        LinkSpeed = $NetworkPort.LinkSpeed
                        Fqdd = $NetworkPartition.Fqdd
                        CurrentMacAddress = $NetworkPartition.CurrentMacAddress
                        PermanentMacAddress = $NetworkPartition.PermanentMacAddress
                        PermanentFcoeMacAddress = $NetworkPartition.PermanentFcoeMacAddress
                        VirtualMacAddress = $NetworkPartition.VirtualMacAddress
                        VirtualIscsiMacAddress = $NetworkPartition.VirtualIscsiMacAddress
                        VirtualFipMacAddress = $NetworkPartition.VirtualFipMacAddress
                        NicMode = $NetworkPartition.NicMode
                        FcoeMode = $NetworkPartition.FcoeMode
                        IscsiMode = $NetworkPartition.IscsiMode
                        MinBandwidth = $NetworkPartition.MinBandwidth
                        MaxBandwidth = $NetworkPartition.MaxBandwidth
                    }
                    $ExportDeviceData += New-NetworkPartitionFromJson $NetworkPortInfo
                }
            }
        }
        return $ExportDeviceData
    }
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}