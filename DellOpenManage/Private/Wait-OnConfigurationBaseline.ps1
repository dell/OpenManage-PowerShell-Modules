function Wait-OnConfigurationBaseline {
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
   Wait for compliance template to complete

 .DESCRIPTION

 .PARAMETER Id

 .EXAMPLE

 .EXAMPLE
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [int] $BaselineId,

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
    Set-CertPolicy
    $BaseUri = "https://$($SessionAuth.Host)"
    $Type        = "application/json"
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

    $MAX_RETRIES = $WaitTime / 10
    $SLEEP_INTERVAL = 10

    $BaselineUrl = $BaseUri + "/api/TemplateService/Baselines"
    $Ctr = 0
    $Status = $null
    do {
        $Ctr++
        Start-Sleep -Seconds $SLEEP_INTERVAL
        $BaselineResponse = Invoke-WebRequest -Uri $BaselineUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($BaselineResponse.StatusCode -eq 200) {
            $BaselineInfo = $BaselineResponse.Content | ConvertFrom-Json
            foreach ($Baseline in $BaselineInfo.'value') {
                if ($Baseline.Id -eq $BaselineId) {
                    $Status = [int]$Baseline.TaskStatus
                    Write-Verbose "Iteration $($Ctr): Status of $($BaselineId) is $($JOB_STATUS_MAP.$Status)"
                    if ($Status -eq 2060) {
                        Write-Verbose "Baseline created successfully..."
                        return $JOB_STATUS_MAP.$Status
                    }
                    elseif ($FailedJobStatuses -contains $Status) {
                        Write-Verbose "Baseline created failed..."
                        return $JOB_STATUS_MAP.$Status
                    }
                    else { continue }
                }
            }
        }
        else {Write-Warning "Unable to get status for $($BaselineId) .. Iteration $($Ctr)"}
    } until ($Ctr -ge $MAX_RETRIES)
}

End {}

}

