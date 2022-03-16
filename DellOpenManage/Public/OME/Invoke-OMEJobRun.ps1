
function Invoke-OMEJobRun {
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
    Run job now
.DESCRIPTION
    Run an existing job by Id
.PARAMETER JobId
    Integer containing JobId
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    [int] JobId
.EXAMPLE
    28991 | Invoke-OMEJobRun -Wait -Verbose
    
    Run job
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [int]$JobId,

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
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $payload = '{
            "JobIds": [0]
        }' | ConvertFrom-Json

        $payload.JobIds = @($JobId)
        $JobPayload = $payload

        $JobURL = $BaseUri + "/api/JobService/Actions/JobService.RunJobs"
        $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
        Write-Verbose $JobPayload
        $JobResponse = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
        if ($JobResponse.StatusCode -eq 204) {
            if ($Wait) {
                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return "Completed"
            }
            Write-Verbose "Job run successful..."
        }
        else {
            Write-Error "Job run failed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

