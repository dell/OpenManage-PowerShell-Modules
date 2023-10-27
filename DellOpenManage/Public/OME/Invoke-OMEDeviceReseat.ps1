using module ..\..\Classes\Device.psm1

function Get-VirtualReseatPayload($Name, $TargetPayload) {
    $Payload = '{
        "JobName": "Virtual_Reseat",
        "JobDescription": " Virtual_Reseat ",
        "Schedule": "startnow",
        "State":"Enabled",
        "Targets": [
            {
            "Id": 50115,
            "Data": "",
            "TargetType": {
                "Id": 1000,
                "Name": "DEVICE"
                }
            }
            ],
            "Params": [
                {
                "Key": "override",
                "Value": "true"
                },
                {
                "Key": "operationName",
                "Value": "VIRTUAL_RESEAT"
                },
                {
                "Key": "deviceTypes",
                "Value": "1000"
                }
            ],
        "JobType": {
            "Id": 3,
            "Name": "DeviceAction_Task",
            "Internal": false
    }}' | ConvertFrom-Json

    $Payload.Targets = $TargetPayload
    $Payload.JobName = $Name
    return $payload
}

function Invoke-OMEDeviceReseat {
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
    Virtual reseat device in OpenManage Enterprise
.DESCRIPTION
    This will submit a job to do a virtual reseat on a Compute device in an MX Chassis
.PARAMETER Name
    Name of the job
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function.
.INPUTS
    Device
.EXAMPLE
    "933NCZZ" | Get-OMEDevice | Invoke-OMEDeviceReseat -Verbose -Wait
    
    Trigger virtual system reseat
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Virtual Reseat $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device[]] $Devices,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
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
            $JobPayload = Get-VirtualReseatPayload -Name $Name -TargetPayload $TargetPayload
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