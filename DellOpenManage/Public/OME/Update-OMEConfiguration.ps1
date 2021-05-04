using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Device.psm1
using module ..\..\Classes\ConfigurationBaseline.psm1

function Get-TargetConfigurationPayload($Targets, $DeviceFilter) {
    $TargetTypeHash = @{}
    $TargetTypeHash.'Id' = 1000
    $TargetTypeHash.'Name' = "DEVICE"
    $ComplianceReportTargetList = @()
    $DeviceFilterIds = $DeviceFilter | Select-Object -ExpandProperty Id
    foreach ($Target in $Targets) {
        $TargetHash = @{}
        if ($DeviceFilterIds.Length -eq 0 -or $DeviceFilterIds -contains $Target) {
            $TargetHash.TargetType = $TargetTypeHash
            $TargetHash.Id = $Target
            $ComplianceReportTargetList += $TargetHash
        }
    }
    return ,$ComplianceReportTargetList # Preceeding comma is a workaround to ensure an array is returned when only a single item is present
}

function Get-ConfigurationPayload($Name, $TemplateId, $TargetPayload) {
    $Payload = '{
        "JobName": "Make Devices Compliant",
        "JobDescription": "Make the selected devices compliant with template",
        "Schedule": "startnow",
        "State": "Enabled",
        "Targets": [
            {
                "Id": 10072,
                "Data": "37KP0Q2",
                "TargetType": {
                    "Id": 1000,
                    "Name": "DEVICE"
                }
            }
        ],
        "Params": [
            {
                "Key": "jobName",
                "Value": "Make Devices Compliant"
            },
            {
                "Key": "jobDesc",
                "Value": "Make the selected devices compliant with template"
            },
            {
                "Key": "schemaId",
                "Value": "34"
            },
            {
                "Key": "templateId",
                "Value": "34"
            },
            {
                "Key": "HAS_IO_POOL",
                "Value": "false"
            },
            {
                "Key": "fileName",
                "Value": "DEPLOY_CONFIG_34.xml"
            },
            {
                "Key": "action",
                "Value": "SERVER_DEPLOY_CONFIG"
            },
            {
                "Key": "shutdownType",
                "Value": "0"
            },
            {
                "Key": "timeToWait",
                "Value": "300"
            },
            {
                "Key": "endHostPowerState",
                "Value": "1"
            },
            {
                "Key": "strictCheckingVlan",
                "Value": "false"
            }
        ],
        "JobType": {
            "@odata.type": "#JobService.JobType",
            "Id": 50,
            "Name": "Device_Config_Task",
            "Internal": false
        }
    }' | ConvertFrom-Json

    $ParamsHashValMap = @{
        "jobName" = [string]$Name
        "schemaId" = [string]$TemplateId
        "templateId" = [string]$TemplateId
    }

    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($ParamsHashValMap.Keys -Contains ($Payload.'Params'[$i].'Key')) {
            $value = $Payload.'Params'[$i].'Key'
            $Payload.'Params'[$i].'Value' = $ParamsHashValMap.$value
        }
    }
    $Payload.Targets = $TargetPayload
    $Payload.JobName = $Name
    return $payload
}

function Update-OMEConfiguration {
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
    Update configuration on devices in OpenManage Enterprise
.DESCRIPTION
    This will use an existing configuration baseline to submit a Job that updates configuration on a set of devices immediately. ***This will force a reboot if necessary***
.PARAMETER Name
    Name of the configuration update job
.PARAMETER Baseline
    Array of type ConfigurationBaseline returned from Get-OMEConfigurationBaseline function
.PARAMETER DeviceFilter
    Array of type Device returned from Get-OMEDevice function. Used to limit the devices updated within the baseline.
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -Wait -Verbose
    Update configuration compliance on all devices in baseline ***This will force a reboot if necessary***
.EXAMPLE
    Update-OMEConfiguration -Name "Make Compliant Test01" -Baseline $("TestBaseline01" | Get-OMEConfigurationBaseline) -DeviceFilter $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") -Wait -Verbose
    Update configuration compliance on filtered devices in baseline ***This will force a reboot if necessary***
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Make Devices Compliant $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false)]
    [Device[]]$DeviceFilter,

    [Parameter(Mandatory)]
    [ConfigurationBaseline]$Baseline,

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

        $BaselineId = $Baseline.Id
        $TemplateId = $Baseline.TemplateId
        if ($Baseline.Targets.Length -gt 0) {
            $TargetPayload = Get-TargetConfigurationPayload $Baseline.Targets $DeviceFilter
            if ($TargetPayload.Length -gt 0) {
                $UpdatePayload = Get-ConfigurationPayload -Name $Name -TemplateId $TemplateId -TargetPayload $TargetPayload
                # Update configuration
                $UpdateJobURL = $BaseUri + "/api/JobService/Jobs"
                $UpdatePayload = $UpdatePayload | ConvertTo-Json -Depth 6
                Write-Verbose $UpdatePayload
                $JobResp = Invoke-WebRequest -Uri $UpdateJobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $UpdatePayload
                if ($JobResp.StatusCode -eq 201) {
                    Write-Verbose "Update job creation successful"
                    $JobInfo = $JobResp.Content | ConvertFrom-Json
                    $JobId = $JobInfo.Id
                    Write-Verbose "Created job $($JobId) to update configuration..."
                    if ($Wait.IsPresent) {
                        $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                        return $JobStatus
                    } else {
                        return $JobId
                    }
                }
                else {
                    Write-Error "Update job creation failed"
                }
            }
        }
        else {
            Write-Warning "No updates found"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

