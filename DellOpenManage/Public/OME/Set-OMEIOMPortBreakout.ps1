using module ..\..\Classes\Device.psm1

function Get-PortBreakoutPayload($Name, $TargetPayload, $BreakoutType, $Ports) {
    $Payload = '{
        "JobName": "Breakout Port",
        "JobDescription": null,
        "Schedule": "startnow",
        "State": "Enabled",
        "JobType": {
            "Id": 3,
            "Name": "DeviceAction_Task",
            "Internal": false
        },
        "Targets": [
            {
                "Id": 10045,
                "Data": "",
                "TargetType": {
                    "Id": 1000,
                    "Name": "DEVICE"
                }
            }
        ],
        "Params": [
            {
                "Key": "breakoutType",
                "Value": "1X40GE"
            },
            {
                "Key": "interfaceId",
                "Value": "DPM4XC1:portgroup1/1/1,DPM4XC1:port-group1/1/2"
            },
            {
                "Key": "operationName",
                "Value": "CONFIGURE_PORT_BREAK_OUT"
            }
        ]
    }' | ConvertFrom-Json

    $Payload.Targets = $TargetPayload
    $Payload.JobName = $Name

    $ParamsHashValMap = @{
        "breakoutType" = $BreakoutType
        "interfaceId" = $Ports
    }

    # Update Params from ParamsHashValMap
    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($ParamsHashValMap.Keys -Contains ($Payload.'Params'[$i].'Key')) {
            $value = $Payload.'Params'[$i].'Key'
            $Payload.'Params'[$i].'Value' = $ParamsHashValMap.$value
        }
    }

    return $payload
}

function Set-OMEIOMPortBreakout {
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
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Set Port Breakout $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory)]
    [Device] $Device,

    [Parameter(Mandatory)]
    [ValidateSet("4X25GE","2X50GE","4X10GE","4X1GE","1X40GE","1X100GE","4X16GFC","4X32GFC","2X32GFC","4X8GFC","1X32GFC","HardwareDefault")]
    [String]$BreakoutType,

    [Parameter(Mandatory)]
    [String] $Ports
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
        $DeviceIds += $Device.Id
        $TargetPayload = Get-JobTargetPayload $DeviceIds
        $PortSplit = $Ports.Split(",")
        $PortsParam = @()
        foreach ($Port in $PortSplit) {
            $PortsParam += "$($Device.DeviceServiceTag):$($Port)"
        }
        $JobPayload = Get-PortBreakoutPayload -Name $Name -TargetPayload $TargetPayload -BreakoutType $BreakoutType -Ports $($PortsParam -join ",")
        # Submit job
        $JobURL = $BaseUri + "/api/JobService/Jobs"
        $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
        Write-Verbose $JobPayload
        $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
        if ($JobResp.StatusCode -eq 201) {
            Write-Verbose "Job creation successful..."
            $JobInfo = $JobResp.Content | ConvertFrom-Json
            $JobId = $JobInfo.Id
            Write-Verbose "Waiting for job $($JobId) to set port breakout until completion..."
            $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
            Write-Verbose "Submitting inventory refresh job"
            $Device | Invoke-OMEInventoryRefresh -Wait
            return $JobStatus
        }
        else {
            Write-Error "Job creation failed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}