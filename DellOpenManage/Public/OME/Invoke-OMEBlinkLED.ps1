using module ..\..\Classes\Device.psm1

function Get-BlinkLEDPayload($Name, $TargetPayload, $Duration, $Unblink) {
    $Payload = '{
        "Id": 0,
        "JobName": "Blink LED",
        "JobDescription": "Blink LED: N Minute(s) or Indefinitely",
        "Schedule": "startnow",
        "State": "Enabled",
        "JobType": {
            "Name": "DeviceAction_Task"
        },
        "Targets": [
            {
                "Id": 10043,
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
                "Value": "IDENTIFY_BLINK_LED"
            }
        ]
}' | ConvertFrom-Json

    $IdentifyState = "2"
    if ($Unblink) {
        $IdentifyState = "0"
        $Duration = "0"
    }
    $ParamName = @{
        "Key" = "identifyState"
        "Value" = $IdentifyState
    }
    $Payload.Params += $ParamName
    $ParamName2 = @{
        "Key" = "durationLimit"
        "Value" = $Duration.ToString()
    }
    $Payload.Params += $ParamName2
    $Payload.Targets = $TargetPayload
    $Payload.JobName = $Name
    return $payload
}

# NOTE To shut off LED blinking the identifyState and durationLimit parameters must be set to 0.

function Invoke-OMEBlinkLED {
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
    Blink led device in OpenManage Enterprise
.DESCRIPTION
    
.PARAMETER Name
    Name of the job
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function.
.PARAMETER Duration
    Default = 30 (minutes), -1 = indefinitely
.PARAMETER Unblink
    Manually stop LED from blinking. For use with indefinite duration. 
.INPUTS
    Device
.EXAMPLE
    "933NCZZ" | Get-OMEDevice | Invoke-OMEBlinkLED -Verbose -Wait
    
    Blink LED

    933NCZZ" | Get-OMEDevice | Invoke-OMEBlinkLED -Unblink -Verbose -Wait
    UnBlink LED

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Blink LED $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device[]] $Devices,

    [Parameter(Mandatory=$false)]
    [int]$Duration = 30,

    [Parameter(Mandatory=$false)]
    [Switch]$Unblink,

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
            $JobPayload = Get-BlinkLEDPayload -Name $Name -TargetPayload $TargetPayload -Duration $Duration -Unblink $Unblink
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