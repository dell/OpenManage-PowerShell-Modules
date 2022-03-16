
function Get-OMESupportAssistCase {
<#
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
   Get list of Identity Pools from OME

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter. Supports regex based matching.
.PARAMETER FilterBy
    Filter the results by ("EventSource", "Id", "ServiceContract", Default="ServiceTag")
 .EXAMPLE
   Get-OMESupportAssistCase | Format-Table
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    $Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("EventSource", "Id", "ServiceContract", "ServiceTag")]
    [String]$FilterBy = "ServiceTag"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    # Add version check for SupportAssist commandlets
    if ($SessionAuth.Version -lt [System.Version]"3.5.0") {
        Write-Error "SupportAssist API not supported in version $($SessionAuth.Version) of OpenManage Enterprise"
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $SupportAssistCasesUrl = $BaseUri  + "/api/SupportAssistService/Cases"
        $SupportAssistCasesData = @()
        $SupportAssistCasesResponse = Get-ApiAllData -BaseUri $BaseUri -Url $SupportAssistCasesUrl -Headers $Headers
        foreach ($SupportAssistCases in $SupportAssistCasesResponse) {
            $SupportAssistCasesData += $SupportAssistCases
        }
        # OData filtering not supported on this API endpoint. Provide basic filtering ability.
        if ($Value.Count -gt 0) { 
            return $SupportAssistCasesData | Where-Object -Property $FilterBy -Match $Value
        } else {
            return $SupportAssistCasesData
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}