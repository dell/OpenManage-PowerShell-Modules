using module ..\Classes\Job.psm1

function Wait-OnJob {
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
   Script to get the list of devices managed by OM Enterprise

 .DESCRIPTION

   This script exercises the OME REST API to get a list of devices
   currently being managed by that instance. For authentication X-Auth
   is used over Basic Authentication

   Note that the credentials entered are not stored to disk.

 .PARAMETER Id

 .EXAMPLE

 .EXAMPLE
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Int[]]$JobId,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
    $Headers     = @{}

    $Headers."X-Auth-Token" = $SessionAuth.Token

    $JOB_STATUS_MAP = @{
        2020 = "Scheduled";
        2030 = "Queued";
        2040 = "Starting";
        2050 = "Running";
        2060 = "Completed";
        2070 = "Failed";
        2090 = "Warning";
        2080 = "New";
        2100 = "Aborted";
        2101 = "Paused";
        2102 = "Stopped";
        2103 = "Canceled"
    }

    $FailedJobStatuses = @(2070, 2090, 2100, 2101, 2102, 2103)

    $SLEEP_INTERVAL = 30
    $MAX_RETRIES = [Math]::Floor($WaitTime / $SLEEP_INTERVAL)

    $Ctr = 0
    if ($JobId -gt 0) {
        do {
            $Ctr++
            Start-Sleep -s $SLEEP_INTERVAL
            $JobResp = $($JobId | Get-OMEJob -FilterBy "Id")
            if ($JobResp) {
                $JobData = $JobResp
                $JobStatus = $JobData.LastRunStatusId
                Write-Verbose "Iteration $($Ctr), Wait $($Ctr * $SLEEP_INTERVAL)s: Status of $($JobId) is $($JOB_STATUS_MAP.$JobStatus)"
                if ($JobStatus -eq 2060) { # Completed
                    Write-Verbose "Job completed successfully..."
                    return $JOB_STATUS_MAP.$JobStatus
                }
                elseif ($JobStatus -eq 2050) { # Running
                    $JobDetails = $($JobId | Get-OMEJob -FilterBy "Id" -Detail)
                    if ($JobDetails) {
                        #$JobDetails.JobDetail | Format-Table | Out-String | Write-Verbose
                        foreach ($Detail in $JobDetails.JobDetail) {
                            $Detail | Format-List | Out-String | Write-Verbose
                        }
                    }
                    else {
                        Write-Warning "Unable to get job execution history info"
                    }
                    continue
                }
                elseif ($FailedJobStatuses -contains $JobStatus) { # Failed, Warning, Aborted, Paused, Stopped, Cancelled
                    $JobDetails = $($JobId | Get-OMEJob -FilterBy "Id" -Detail)
                    if ($JobDetails) {
                        Write-Warning "Job failed..."
                        #$JobDetails.JobDetail | Format-Table | Out-String | Write-Verbose
                        foreach ($Detail in $JobDetails.JobDetail) {
                            $Detail | Format-List | Out-String | Write-Verbose
                        }
                    }
                    else {
                        Write-Warning "Unable to get job execution history info"
                    }
                    return $JOB_STATUS_MAP.$JobStatus
                }
                else { continue }
            }
            else {
                Write-Warning "Unable to get status for $($JobId) .. Iteration $($Ctr)"
            }
        } until ($Ctr -ge $MAX_RETRIES)
    } else {
        Write-Error "Invalid JobId $($JobId)"
    }
}

End {}

}

