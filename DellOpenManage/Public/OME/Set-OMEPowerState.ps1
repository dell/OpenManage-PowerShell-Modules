$PowerControlStateMap = @{
    "On" = "2";
    "Off" = "12";
    "ColdBoot" = "5";
    "WarmBoot" ="10";
    "ShutDown" = "8"
}

function Get-DevicePowerState($BaseUri, $Headers, $Type, $DeviceId) {
    $DeviceUrl = $BaseUri + "/api/DeviceService/Devices($($DeviceId))"
    $DevResp = Invoke-WebRequest -Uri $DeviceUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
    $PowerState = $null
    if ($DevResp.StatusCode -eq 200){
        $DevInfo = $DevResp.Content | ConvertFrom-Json
        $PowerState = $DevInfo.PowerState
    }
    return $PowerState
}

function Get-JobServicePayload() {
    $POWER_CONTROL = '{
    "power_control_details": {
            "Id": 0,
            "JobName": "System Reset",
            "JobDescription": "DeviceAction_Task",
            "Schedule": "startnow",
            "State": "Enabled",
            "JobType": {
                "Id": 3,
                "Name": "DeviceAction_Task"
            },
            "Params": [
                {
                    "Key": "operationName",
                    "Value": "VIRTUAL_RESEAT"
                },
                {
                    "Key": "connectionProfile",
                    "Value": "0"
                }
            ],
            "Targets": [
                {
                    "Id": 26593,
                    "Data": "",
                    "TargetType":
                    {
                        "Id": 1000,
                        "Name": "DEVICE"
                    }
                }
            ]
        }
    }' |ConvertFrom-Json
    return $POWER_CONTROL

}

function Get-UpdatedJobServicePayload ($JobServicePayload, $DeviceId, $State) {
    $JobName = @{
        "On" = "Power On";
        "Off" = "Power Off";
        "ColdBoot" = "Power Cycle"
        "WarmBoot" = "System Reset (Warm Boot)"
        "ShutDown" = "Graceful Shutdown"
    }
    $PowerControlDetails = $JobServicePayload."power_control_details"
    $PowerControlDetails."JobName" = $JobName[$State]
    $PowerControlDetails."JobDescription"="Power Control Task:"+$JobName[$State]
    $PowerControlDetails."Params"[0]."Value" = "POWER_CONTROL"
    $PowerControlDetails."Params"[1]."Key" = "powerState"
    $PowerControlDetails."Params"[1]."Value" = $PowerControlStateMap[$State]
    $PowerControlDetails."Targets"[0]."Id" = $DeviceId
    return $PowerControlDetails
}
function Set-OMEPowerState {
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
    Set power state of server
.DESCRIPTION
.PARAMETER Device
    Array of type Device returned from Get-OMEDevice function. Used to limit the devices updated within the baseline.
.PARAMETER State
    String to represent the desired power state of device. ("On", "Off", "ColdBoot", "WarmBoot", "ShutDown")
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    Device[]
.EXAMPLE
    Set-OMEPowerState -State "On" -Devices $("37KP0ZZ" | Get-OMEDevice -FilterBy "ServiceTag")
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Device[]]$Devices,

    [Parameter(Mandatory)]
    [ValidateSet("On", "Off", "ColdBoot", "WarmBoot","ShutDown")]
    [String]$State,

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
        $JobUrl = $BaseUri + "/api/JobService/Jobs"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $PowerStateMap=@{ "On"="17";"Off"="18";"PoweringOn"="20";"PoweringOff"="21"}
        $PowerState = Get-DevicePowerState -BaseUri $BaseUri -Headers $Headers -Type $Type -DeviceId $Devices.Id
        if($PowerState){
            if($PowerControlStateMap[$State] -eq $PowerState ){
                Write-Verbose "Device is already in the desired state."
            }elseif(($State -eq "On") -and ($PowerState -eq $PowerStateMap["PoweringOn"])){
                Write-Verbose "Device is already in the desired state."
            }
            elseif(($State -eq "Off") -and ($PowerState -eq $PowerStateMap["PoweringOff"])){
                Write-Verbose "Device is already in the desired state. "
            }
            else{
                $JobServicePayload = Get-JobServicePayload
                $UpdatedJobServicePayload = Get-UpdatedJobServicePayload -JobServicePayload $JobServicePayload -DeviceId $Devices.Id -State $State 
                $UpdatedJobServicePayload = $UpdatedJobServicePayload |ConvertTo-Json -Depth 6
                Write-Verbose $UpdatedJobServicePayload
                $JobResponse = Invoke-WebRequest -Uri $JobUrl -Method Post -Body $UpdatedJobServicePayload -ContentType $Type -Headers $Headers
                if ($JobResponse.StatusCode -eq 201) {
                    $JobInfo = $JobResponse.Content | ConvertFrom-Json
                    $JobId = $JobInfo.Id
                    Write-Verbose "Created job $($JobId) to set power state..."
                    if ($Wait) {
                        $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                        return $JobStatus
                    }
                }
                else {
                    Write-Error "Unable to $($State) device..."
                    Write-Error $JobResponse
                }
            }
        } 
        else {
            Write-Error "Unable to fetch powerstate for device with id $($Devices.Id))"
        }
    } 
    Catch {
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) 
    }
}

End {}

}

