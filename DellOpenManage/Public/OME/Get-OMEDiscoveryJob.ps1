
using module ..\..\Classes\DiscoveryJob.psm1

function Get-OMEDiscoveryJob {
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

​​​​​Changes from Qualcomm Innovation Center, Inc. are provided under the following license:
Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause-Clear
#>

<#
.SYNOPSIS
    Get firmware/driver catalog from OpenManage Enterprise
.DESCRIPTION
    Returns all catalogs if no input received
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="Name", "Id")
.INPUTS
    String[]
.EXAMPLE
    Get-OMEDiscovery | Format-Table

    Get all discovery jobs
.EXAMPLE
    "DRM" | Get-OMEDiscovery | Format-Table
    
    Get job by name by name
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id")]
    [String]$FilterBy = "Name"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
   

        $FilterMap = @{
            'Id'='JobId'
            'Name'='JobName'
        }
        $FilterExpr  = $FilterMap[$FilterBy]
        if ($Value) {
            $FilterString = "?`$filter=$($FilterExpr) eq '$($Value)'"
        }
        $DiscoveryUrl   = "$($BaseUri)/api/DiscoveryConfigService/Jobs$($FilterString)"
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token


        $DiscoveryData = @()
        $NextLinkUrl = $DiscoveryUrl
        while($NextLinkUrl) {
            Write-Verbose $NextLinkUrl
            $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
            if($NextLinkResponse.StatusCode -in 200, 201)
            {
                $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                foreach ($NextLinkItem in $NextLinkData.'value') {
                    $DiscoveryData += New-DiscoveryJobFromJson $NextLinkItem
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
                Write-Warning "Unable to retrieve Discovery Jobs from $($NextLinkUrl)"
                $NextLinkUrl = $null
            }
        }
        return $DiscoveryData

    }
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String)
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}