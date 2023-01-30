using module ..\..\Classes\Device.psm1

function Get-PortBreakoutPayload($Name, $TargetPayload, $BreakoutType, $PortGroups) {
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
        "interfaceId" = $PortGroups
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
    Configure port breakout on IOM devices
.DESCRIPTION
    Only supports configuring 1 IOM device per execution but multiple port groups can be configured with the same BreakoutType.
.PARAMETER Name
    Name of the configure port breakout job
.PARAMETER Device
    Object of type Device returned from Get-OMEDevice function. Only supports configuring 1 device per execution.
.PARAMETER BreakoutType
    String specifing the breakout type. ("4X25GE","2X50GE","4X10GE","4X1GE","1X40GE","1X100GE","4X16GFC","4X32GFC","2X32GFC","4X8GFC","1X32GFC","HardwareDefault")
.PARAMETER PortGroups
    Comma delimited string specifing the port group(s) to configure.
.PARAMETER RefreshInventory
    Refresh IOM device inventory upon job completion. Required to update the OME-M UI with changes to port breakout. Requires -Wait parameter to be specified.
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    Set-OMEIOMPortBreakout -Device $("C38S9T2" | Get-OMEDevice) -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait -Verbose

    Configure port for 4 x 10GE breakout and wait for job to complete
.EXAMPLE
    Set-OMEIOMPortBreakout -Device $("C38S9T2" | Get-OMEDevice) -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait -RefreshInventory -Verbose

    Configure port for 4 x 10GE breakout, wait for job to complete and refresh device inventory upon completion.
.EXAMPLE
    Set-OMEIOMPortBreakout -Device $("C38S9T2" | Get-OMEDevice) -BreakoutType "4X8GFC" -PortGroups "port-group1/1/15,port-group1/1/16" -Verbose
    
    Configure multiple ports for 4 x 8G FC
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
    [String] $PortGroups,

    [Parameter(Mandatory=$false)]
    [Switch]$RefreshInventory,

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
        $DeviceIds += $Device.Id
        $TargetPayload = Get-JobTargetPayload $DeviceIds
        $PortSplit = $PortGroups.Split(",")
        $PortGroupsParam = @()
        foreach ($Port in $PortSplit) {
            $PortGroupsParam += "$($Device.DeviceServiceTag):$($Port)"
        }
        $JobPayload = Get-PortBreakoutPayload -Name $Name -TargetPayload $TargetPayload -BreakoutType $BreakoutType -PortGroups $($PortGroupsParam -join ",")
        # Submit job
        $JobURL = $BaseUri + "/api/JobService/Jobs"
        $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
        Write-Verbose $JobPayload
        $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
        if ($JobResp.StatusCode -eq 201) {
            $JobInfo = $JobResp.Content | ConvertFrom-Json
            $JobId = $JobInfo.Id
            Write-Verbose "Job $($JobId) created successful..."
            if ($Wait) {
                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                if ($JobStatus -eq "Completed" -and $RefreshInventory) {
                    $JobStatus = $($Device | Invoke-OMEInventoryRefresh -Wait)
                }
                return $JobStatus
            } else {
                return $JobId
            }
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