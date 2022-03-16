function Get-OMEReport {
<#
_author_ = Raajeev Kalyanaraman <raajeev.kalyanaraman@Dell.com>

Copyright (c) 2021 Dell EMC Corporation

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
   Script to retrieve the list of pre-defined reports 

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.

 .EXAMPLE
   Get-OMEReport | Format-Table
#>   

    [CmdletBinding()]
    param(
    )

    if (!$(Confirm-IsAuthenticated)){
        Return
    }

    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $ReportUrl = $BaseUri  + "/api/ReportService/ReportDefs"
        $ReportData = @()
        $ReportResponse = Get-ApiAllData -BaseUri $BaseUri -Url $ReportUrl -Headers $Headers
        foreach ($Report in $ReportResponse) {
            $ReportData += $Report
        }
        return $ReportData
    }
    Catch {
        Resolve-Error $_
    }

}