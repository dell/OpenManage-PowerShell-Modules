using module ..\..\Classes\Device.psm1

function Get-InventoryRefreshPayload($Name, $TargetPayload) {
    $Payload = '{
        "Id":0,
        "JobName":"Inventory Task Device",
        "JobDescription":"Inventory Task Device",
        "Schedule":"startnow",
        "State":"Enabled",
        "JobType": {
            "Id":8,
            "Name":"Inventory_Task"
        },
        "Targets":[
            {
                "Id": 25915,
                "Data": "",
                "TargetType":
                {
                "Id":1000,
                "Name":"DEVICE"
                }
            }
        ]
    }' | ConvertFrom-Json

    $Payload.Targets = $TargetPayload
    $Payload.JobName = $Name
    return $payload
}

function Invoke-OMEInventoryRefresh {
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
    Refresh inventory on devices in OpenManage Enterprise
.DESCRIPTION
    This will submit a job to refresh the inventory on provided Devices.
.PARAMETER Name
    Name of the inventory refresh job
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function.
.INPUTS
    Device
.EXAMPLE
    "PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Invoke-OMEInventoryRefresh -Verbose
    Create separate inventory refresh job for each device in list
.EXAMPLE
    ,$("PowerEdge R640" | Get-OMEDevice -FilterBy "Model") | Invoke-OMEInventoryRefresh -Verbose
    Create one inventory refresh job for all devices in list. Notice the preceeding comma before the device list.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Inventory Task Device $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device[]] $Devices,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
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
        $Type  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $DeviceIds = @()
        foreach ($Device in $Devices) {
            $DeviceIds += $Device.Id
        }
        if ($DeviceIds.Length -gt 0) {
            $TargetPayload = Get-JobTargetPayload $DeviceIds
            $JobPayload = Get-InventoryRefreshPayload -Name $Name -TargetPayload $TargetPayload
            # Submit job
            $JobURL = $BaseUri + "/api/JobService/Jobs"
            $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
            Write-Verbose $JobPayload
            $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
            if ($JobResp.StatusCode -eq 201) {
                Write-Verbose "Job creation successful..."
                $JobInfo = $JobResp.Content | ConvertFrom-Json
                $JobId = $JobInfo.Id
                Write-Verbose "Created job $($JobId) to refresh inventory..."
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                } else {
                    return $JobId
                }
            }
            else {
                Write-Error "Job creation failed"
            }
        } else {
            Write-Warning "No devices found"
            return "Completed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}