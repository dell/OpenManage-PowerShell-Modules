using module ..\Classes\Job.psm1

function Wait-iDRACOnJob {
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
    [Parameter(Mandatory, ValueFromPipeline)]
    [String[]]$JobId,

    [Parameter(Mandatory)]
    [String]$BaseUri,
    
    [Parameter(Mandatory)]
    [pscredential]$Credentials,
    
    [Parameter(Mandatory=$false)]
    [String]$WaitForStatus = "Completed",

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

Begin {
}
Process {
    Set-CertPolicy
    $ContentType  = "application/json"
    $Headers = @{}

    $MAX_RETRIES = $WaitTime / 10
    $SLEEP_INTERVAL = 30

    #New,Starting,Running,Suspended,Interrupted,Pending,Stopping,Completed,Cancelled,Exception,Service,UserIntervention,Continue

    $FailedJobStatuses = @("Suspended", "Interrupted", "Stopping", "Cancelled", "Exception")

    $Ctr = 0
    if ($JobId) {
        do {
            $Ctr++
            Start-Sleep -s $SLEEP_INTERVAL
            $JobURL = $BaseUri + "/Managers/iDRAC.Embedded.1/Jobs/$($JobId)"
            $JobResp = Invoke-WebRequest -Uri $JobURL -Credential $Credentials -Headers $Headers -ContentType $ContentType -Method GET
            $JobData = $JobResp.Content | ConvertFrom-Json
            if ($JobResp) {
                $JobStatus = $JobData.JobState
                Write-Verbose "Iteration $($Ctr), Wait $($Ctr * $SLEEP_INTERVAL)s: Status of $($JobId) is $($JobStatus)"
                if ($JobStatus -eq $WaitForStatus) { 
                    Write-Verbose "Job status $($WaitForStatus)..."
                    return $JobStatus
                }
                elseif ($JobStatus -eq "Running") { 
                    $JobData | Format-List | Out-String | Write-Verbose
                    continue
                }
                elseif ($FailedJobStatuses -contains $JobStatus) { # Failed, Warning, Aborted, Paused, Stopped, Cancelled
                    $JobData | Format-List | Out-String | Write-Verbose
                    return $JobStatus
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

