using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Device.psm1
using module ..\..\Classes\Baseline.psm1

function Get-TargetPayload($ComplianceReportList) {
    $TargetTypeHash = @{}
    $TargetTypeHash.'Id' = 1000
    $TargetTypeHash.'Name' = "DEVICE"
    $ComplianceReportTargetList = @()
    foreach ($reportHash in $ComplianceReportList) {
        $reportHash.'TargetType' = $TargetTypeHash
        $ComplianceReportTargetList += $reportHash
    }
    return $ComplianceReportTargetList
}

function Get-FirmwareApplicablePayload($CatalogId, $RepositoryId, $BaselineId, $TargetPayload, $StageUpdate, $ResetiDRAC, $ClearJobQueue) {
    $Payload = '{
        "JobName": "Update Firmware-Test",
        "JobDescription": "Firmware Update Job",
        "Schedule": "startNow",
        "State": "Enabled",
        "JobType": {
            "Id": 5,
            "Name": "Update_Task"
        },
        "Params": [{
            "Key": "complianceReportId",
            "Value": "12"
        },
		{
            "Key": "repositoryId",
            "Value": "1104"
        },
		{
            "Key": "catalogId",
            "Value": "604"
        },
		{
            "Key": "operationName",
            "Value": "INSTALL_FIRMWARE"
        },
		{
            "Key": "complianceUpdate",
            "Value": "true"
        },
		{
            "Key": "signVerify",
            "Value": "true"
        },
        {
            "Key": "clearJobQueue",
            "Value": "false"
        },
        {
            "Key": "firmwareReset",
            "Value": "false"
        },
		{
            "Key": "stagingValue",
            "Value": "false"
        }],
        "Targets": []
    }' | ConvertFrom-Json

    $ParamsHashValMap = @{
        "complianceReportId" = [string]$BaselineId
        "repositoryId" = [string]$RepositoryId
        "catalogId" = [string]$CatalogId
        "stagingValue" = if ($StageUpdate) { "true" } else { "false"}
        "clearJobQueue" = if ($ClearJobQueue) { "true" } else { "false"}
        "firmwareReset" = if ($ResetiDRAC) { "true" } else { "false"}
    }

    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($ParamsHashValMap.Keys -Contains ($Payload.'Params'[$i].'Key')) {
            $value = $Payload.'Params'[$i].'Key'
            $Payload.'Params'[$i].'Value' = $ParamsHashValMap.$value
        }
    }
    $Payload."Targets" += $TargetPayload
    return $payload
}

function Update-OMEFirmware {
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
    Update firmware on devices in OpenManage Enterprise
.DESCRIPTION
    This will use an existing firmware baseline to submit a Job that updates firmware on a set of devices. 
.PARAMETER Baseline
    Array of type Baseline returned from Get-Baseline function
.PARAMETER DeviceFilter
    Array of type Device returned from Get-OMEDevice function. Used to limit the devices updated within the baseline.
.PARAMETER ComponentFilter
    String to represent component name. Used to limit the components updated within the baseline. Supports regex via Powershell -match
.PARAMETER ResetiDRAC
    This option will restart the iDRAC. Occurs immediately, regardless if StageForNextReboot is set
.PARAMETER ClearJobQueue
    This option clears any active or pending jobs. Occurs immediately, regardless if StageForNextReboot is set
.PARAMETER UpdateSchedule
    Determines when the updates will be performed. (Default="Preview", "RebootNow", "StageForNextReboot")
.PARAMETER UpdateAction
    Determines what type of updates will be performed. (Default="Upgrade", "Downgrade", "All")
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) | Format-Table
    Display device compliance report for all devices in baseline. No updates are installed by default.
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "RebootNow" 
    Update firmware on all devices in baseline immediately ***Warning: This will force a reboot of all servers
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot"
    Update firmware on all devices in baseline on next reboot
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow" 
    Update firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -ComponentFilter "iDRAC" -UpdateSchedule "StageForNextReboot" -ClearJobQueue 
    Update firmware on specific components in baseline on next reboot and clear job queue before update
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [Device[]]$DeviceFilter,

    [Parameter(Mandatory=$false)]
    [String]$ComponentFilter,

    [Parameter(Mandatory)]
    [Baseline]$Baseline,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Preview", "RebootNow", "StageForNextReboot")]
    [String]$UpdateSchedule = "Preview",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Upgrade", "Downgrade", "All")]
    [String[]]$UpdateAction = "Upgrade",

    [Parameter(Mandatory=$false)]
    [Switch]$ResetiDRAC,

    [Parameter(Mandatory=$false)]
    [Switch]$ClearJobQueue,

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

        $StageUpdate = $true
        $BaselineId = $Baseline.Id
        $CatalogId = $Baseline.CatalogId
        $RepositoryId = $Baseline.RepositoryId
        if ($UpdateSchedule -eq "Preview") { # Only show report, do not perform any updates
            return Get-OMEFirmwareCompliance -Baseline $Baseline -DeviceFilter $DeviceFilter -ComponentFilter $ComponentFilter -UpdateAction $UpdateAction -Output "Report"
        } else { # Apply updates
            if ($UpdateSchedule -eq "RebootNow") {
                $StageUpdate = $false
            } elseif ($UpdateSchedule -eq "StageForNextReboot") {
                $StageUpdate = $true
            }
            $ComplianceReportList = Get-OMEFirmwareCompliance -Baseline $Baseline -DeviceFilter $DeviceFilter -ComponentFilter $ComponentFilter -UpdateAction $UpdateAction -Output "Data"
            if ($ComplianceReportList.Length -gt 0) {
                $TargetPayload = Get-TargetPayload $ComplianceReportList
                if ($TargetPayload.Length -gt 0) {
                    $UpdatePayload = Get-FirmwareApplicablePayload -CatalogId $CatalogId -RepositoryId $RepositoryId -BaselineId $BaselineId -TargetPayload $TargetPayload -StageUpdate $StageUpdate -ResetiDRAC $ResetiDRAC.IsPresent -ClearJobQueue $ClearJobQueue.IsPresent
                    # Update firmware
                    $UpdateJobURL = $BaseUri + "/api/JobService/Jobs"
                    $UpdatePayload = $UpdatePayload | ConvertTo-Json -Depth 6
                    Write-Verbose $UpdatePayload
                    $JobResp = Invoke-WebRequest -Uri $UpdateJobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $UpdatePayload
                    if ($JobResp.StatusCode -eq 201) {
                        Write-Verbose "Update job creation successful"
                        $JobInfo = $JobResp.Content | ConvertFrom-Json
                        $JobId = $JobInfo.Id
                        Write-Verbose "Created job $($JobId) to update firmware..."
                        if ($Wait) {
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
    } 
    Catch {
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

