﻿using module ..\..\Classes\Device.psm1

function Get-ChassisNamePayload($Name, $TargetPayload) {
    $Payload = '{
        "JobName": "Update Chassis Name",
        "JobDescription": "Update Chassis Name",
        "Schedule": "startnow",
        "State": "Enabled",
        "Targets": [
            {
                "Id": 25016,
                "Data": "",
                "TargetType": {
                    "Id": 1000,
                    "Name": "DEVICE"
                }
            }
        ],
        "Params": [
            {
                "Key": "operationName",
                "Value": "SET_NAME"
            }
        ],
        "JobType": {
            "Id": 3,
            "Name": "DeviceAction_Task"
        }
    }' | ConvertFrom-Json

    $Payload.Targets = $TargetPayload
    $ParamName = @{
        "Key" = "name"
        "Value" = $Name
    }
    $Payload.Params += $ParamName

    return $Payload

}

function Set-OMEChassisName {
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
    Set chassis name
.DESCRIPTION
.PARAMETER Chassis
    Object of type Device returned from Get-OMEDevice function. Must be a Chassis device type.
.PARAMETER Name
    String to represent the Chassis name
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    Device
.EXAMPLE
    Set-OMEChassisName -Name "TESTMX7000-1" -Chassis $("C38V9ZZ" | Get-OMEDevice) -Wait -Verbose
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Device]$Chassis,

        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory = $false)]
        [Switch]$Wait,

        [Parameter(Mandatory = $false)]
        [int]$WaitTime = 3600
    )

    Begin {}
    Process {
        if (!$(Confirm-IsAuthenticated)) {
            Return
        }
        Try {
            if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
            $BaseUri = "https://$($SessionAuth.Host)"
            $JobUrl = $BaseUri + "/api/JobService/Jobs"
            $Type = "application/json"
            $Headers = @{}
            $Headers."X-Auth-Token" = $SessionAuth.Token

            $DeviceIds = @()
            $DeviceIds += $Chassis.Id
            if ($Chassis.Type -eq 2000) {
                $TargetPayload = Get-JobTargetPayload $DeviceIds

                $ChassisNamePayload = Get-ChassisNamePayload -TargetPayload $TargetPayload -Name $Name
                $ChassisNamePayload = $ChassisNamePayload | ConvertTo-Json -Depth 6
                Write-Verbose $ChassisNamePayload
                $JobResponse = Invoke-WebRequest -Uri $JobUrl -UseBasicParsing -Method Post -Body $ChassisNamePayload -ContentType $Type -Headers $Headers
                if ($JobResponse.StatusCode -eq 201) {
                    $JobInfo = $JobResponse.Content | ConvertFrom-Json
                    $JobId = $JobInfo.Id
                    Write-Verbose "Created job $($JobId) to set chassis name..."
                    if ($Wait) {
                        $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                        return $JobStatus
                    }
                    else {
                        return $JobId
                    }
                }
                else {
                    Write-Error "Unable to $($State) device..."
                    Write-Error $JobResponse
                    return "Failed"
                }
            } 
            else {
                throw [System.Exception]::new("DeviceException", "Device must be of type Chassis")
            }
        } 
        Catch {
            Resolve-Error $_
        }
    }

    End {}

}

