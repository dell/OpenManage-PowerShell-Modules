using module ..\..\Classes\Device.psm1

function Remove-OMEDevice {
<#
Copyright (c) 2023 Dell EMC Corporation

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
    Remove device from OpenManage Enterprise
.DESCRIPTION
    Remove device from OpenManage Enterprise
.PARAMETER Device
    Object of type Device returned from Get-OMEDevice
.INPUTS
    None
.EXAMPLE
    "C86D0ZZ" | Get-OMEDevice | Remove-OMEDevice
    
    Remove device
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Device[]]$Devices
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $RemoveDeviceUrl = $BaseUri + "/api/DeviceService/Actions/DeviceService.RemoveDevices"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Payload ='{
            "DeviceIds":[0]
        }' | ConvertFrom-Json
        
        $DeviceIds = @()
        foreach ($Device in $Devices) {
            $DeviceIds += $Device.Id
        }
        $Payload.DeviceIds = $DeviceIds
        $Payload = $Payload | ConvertTo-Json -Depth 6
        Write-Verbose $Payload
        Write-Verbose $RemoveDeviceUrl
        $GroupResponse = Invoke-WebRequest -Uri $RemoveDeviceUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Payload
        Write-Verbose "Removing device..."
        if ($GroupResponse.StatusCode -eq 204) {
            Write-Verbose "Remove device successful..."
        }
        else {
            Write-Error "Remove device failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

