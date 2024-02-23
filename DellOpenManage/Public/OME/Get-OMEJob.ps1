function Get-ExecutionHistoryDetail($BaseUri, $JobId, $Headers, $Type) {
    $JobExecUrl = $BaseUri  + "/api/JobService/Jobs($JobId)/ExecutionHistories"
    $ExecResp = Invoke-WebRequest -UseBasicParsing -Uri $JobExecUrl -Method Get -Headers $Headers -ContentType $Type
    $HistoryDetails = @()
    if ($ExecResp.StatusCode -in 200, 201) {
        $ExecRespInfo = $ExecResp.Content | ConvertFrom-Json
        foreach ($ExecRespValue in $ExecRespInfo.value) {
            $HistoryId = $ExecRespValue.Id
            $ExecHistoryUrl = "$($JobExecUrl)($($HistoryId))/ExecutionHistoryDetails"
            $HistoryResp = Invoke-WebRequest -UseBasicParsing -Uri $ExecHistoryUrl -Method Get -Headers $Headers -ContentType $Type
            if ($HistoryResp.StatusCode -in 200, 201) {
                $HistoryData = $HistoryResp.Content | ConvertFrom-Json
                foreach ($HistoryDetail in $HistoryData.value) {
                    $HistoryDetails += $HistoryDetail
                }
            }
            else {
                Write-Warning "Unable to get job execution history details"
            }
        }
        return $HistoryDetails
    }
    else {
        Write-Warning "Unable to get job execution history info"
    }

}

function Get-OMEJob {
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
    Get job from OpenManage Enterprise
.DESCRIPTION

.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER Detail
    Show detailed job info such as progress, elapsed time or output
.PARAMETER FilterBy
    Filter the results by (Default="Id", "Status", "LastRunStatus", "Type", "State")
.INPUTS
    String[]
.EXAMPLE
    Get-OMEJOb | Format-Table

    List all jobs
.EXAMPLE
    13852 | Get-OMEJob -Detail -Verbose

    Get job by Id
.EXAMPLE
    5 | Get-OMEJob -FilterBy "Type" | Format-Table

    Get job by job type
.EXAMPLE
    2060 | Get-OMEJob -FilterBy "LastRunStatus" | Format-Table

    Get job by last run status
.EXAMPLE
    "Enabled" | Get-OMEJob -FilterBy "State" | Format-Table
    
    Get job by state
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [Switch]$Detail,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Id", "Status", "LastRunStatus", "Type", "State")]
    [String]$FilterBy = "Id"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $NextLinkUrl = $null
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $FilterMap = @{
            'Id'='Id'
            'LastRunStatus'='LastRunStatus/Id'
            'Type'='JobType/Id'
            'State'='State'
        }
        $FilterExpr  = $FilterMap[$FilterBy]

        $JobUrl = $BaseUri  + "/api/JobService/Jobs"
        if ($Value) {
            if ($FilterBy -ne 'State') {
                $JobUrl += "?`$filter=$($FilterExpr) eq $($Value)"
            }
            else {
                $JobUrl += "?`$filter=$($FilterExpr) eq '$($Value)'"
            }
        }

        $JobData = @()
        $JobResponse = Invoke-WebRequest -UseBasicParsing -Uri $JobUrl -Headers $Headers -Method Get -ContentType $Type
        if ($JobResponse.StatusCode -in 200, 201) {
            $JobInfo = $JobResponse.Content | ConvertFrom-Json
            if ($JobInfo.value) { # Multiple jobs returned
                foreach ($JobValue in $JobInfo.value) {
                    if ($Detail) {
                        $JobDetailData = Get-ExecutionHistoryDetail -BaseUri $BaseUri -JobId $JobValue.Id -Headers $Headers -Type $Type
                        $JobData += New-JobFromJson -Job $JobValue -JobDetails $JobDetailData
                    } else {
                        $JobData += New-JobFromJson -Job $JobValue
                    }
                }
                if ($JobInfo.'@odata.nextLink') {
                    $NextLinkUrl = $BaseUri + $JobInfo.'@odata.nextLink'
                }
                while($NextLinkUrl) {
                    $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                    if($NextLinkResponse.StatusCode -in 200, 201)
                    {
                        $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                        foreach ($NextLinkJob in $NextLinkData.'value') {
                            $JobData += New-JobFromJson -Job $NextLinkJob
                        }
                        if ($NextLinkData.'@odata.nextLink') {
                            $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink'
                        }
                        else {
                            $NextLinkUrl = $null
                        }
                    }
                    else
                    {
                        Write-Warning "Unable to get nextlink response for $($NextLinkUrl)"
                        $NextLinkUrl = $null
                    }
                }
            }
            return $JobData
        }
        else {
            Write-Error "Unable to get JobId"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

