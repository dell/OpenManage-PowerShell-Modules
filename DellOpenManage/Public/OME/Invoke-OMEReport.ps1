﻿function Format-OutputInfo($IpAddress,$Headers,$Type,$ReportId) {
    $BaseUri = "https://$($SessionAuth.Host)"
    $Type        = "application/json"
    $Headers     = @{}
    $Headers."X-Auth-Token" = $SessionAuth.Token
    $ReportDeets = $BaseUri + "/api/ReportService/ReportDefs($($ReportId))/ReportResults"
    $NextLinkUrl = $null
    $OutputArray = @()
    $ColumnNames = @()
    $DeetsResp = Invoke-WebRequest -Uri $ReportDeets -UseBasicParsing -Headers $Headers -Method Get -ContentType $Type
    if ($DeetsResp.StatusCode -in 200, 201){
        $DeetsInfo = $DeetsResp.Content | ConvertFrom-Json
        $ColumnNames = $DeetsInfo.ResultRowColumns | ForEach-Object{$_.Name}
        Write-Verbose "Extracting results for report ($($ReportId))"
        $ResultUrl = $BaseUri + "/api/ReportService/ReportDefs($($ReportId))/ReportResults/ResultRows"
        
        $RepResult = Invoke-WebRequest -Uri $ResultUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($RepResult.StatusCode -in 200, 201) {
            $RepInfo = $RepResult.Content | ConvertFrom-Json
            $totalRepResults = [int]($RepInfo.'@odata.count')
            if ($totalRepResults -gt 0) {
                $ReportResultList = $RepInfo.Value
                if ($RepInfo.'@odata.nextLink'){
                    $NextLinkUrl = $BaseUri + $RepInfo.'@odata.nextLink'
                }
                while ($NextLinkUrl){
                    $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                    if ($NextLinkResponse.StatusCode -in 200, 201) {
                        $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                        $ReportResultList += $NextLinkData.'value'
                        if ($NextLinkData.'@odata.nextLink'){
                            $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink'
                        }else{
                            $NextLinkUrl = $null
                        }
                    }else {
                        Write-Error "Unable to get full set of report results"
                        $NextLinkUrl = $null
                    }
                }
                foreach ($value in $ReportResultList) {
                    $resultVals = $value.Values
                    $tempHash = [ordered]@{}
                    for ($i =0; $i -lt $ColumnNames.Count; $i++) {
                        $tempHash[$ColumnNames[$i]] = $resultVals[$i]
                    }
                    $outputArray += , $tempHash
                }
                return $outputArray.Foreach({[PSCustomObject]$_})
            }
            else {
                Write-Warning "No result data retrieved for report ($($ReportId))"
            }
        }
        else {
            Write-Warning "Unable to get report results for $($ReportId)"
        }
    }
    else {
        Write-Warning "Unable to create mapping for report data columns"
    }
}
function Invoke-OMEReport {
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
    Invoke report generation and display results
.DESCRIPTION

.PARAMETER ReportId
    Integer Id of report to execute
.PARAMETER GroupId
    Filter group Id
.INPUTS
    None
.EXAMPLE
    Invoke-OMEReport -ReportId 11709
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [uint64] $ReportId,

    [Parameter(Mandatory=$false)]
    [uint64] $GroupId = 0        
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type        = "application/json"
        $Headers     = @{}

        $Headers."X-Auth-Token" = $SessionAuth.Token
        $ExecRepUrl = $BaseUri + "/api/ReportService/Actions/ReportService.RunReport"
        $RepPayload = @{"ReportDefId"=$ReportId; "FilterGroupId"=$GroupId} | ConvertTo-Json
        Write-Verbose $RepPayload
        
        $ReportResp = Invoke-WebRequest -Uri $ExecRepUrl -UseBasicParsing -Method Post -Headers $Headers -ContentType $Type -Body $RepPayload
        if ($ReportResp.StatusCode -in 200, 201) {
            $JobId = $ReportResp.Content
            $JobStatus = $($JobId | Wait-OnJob)
            if ($JobStatus -eq 'Completed') {
                return Format-OutputInfo -IpAddres $IpAddress -Headers $Headers -Type $Type -ReportId $ReportId      
            }
        } else {
            Write-Error "Unable to retrieve reports from $($IpAddress)"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

