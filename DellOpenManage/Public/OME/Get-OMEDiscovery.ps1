
using module ..\..\Classes\Discovery.psm1
function Get-OMEDiscovery {
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
    [String[]]$Value,

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
        $DiscoveryUrl   = $BaseUri + "/api/DiscoveryConfigService/DiscoveryConfigGroups"
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $DiscoveryData = @()
        $DiscoveryResp = Invoke-WebRequest -Uri $DiscoveryUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($DiscoveryResp.StatusCode -eq 200) {
            $DiscoveryInfo = $DiscoveryResp.Content | ConvertFrom-Json
            foreach ($Discovery in $DiscoveryInfo.'value') {
                if ($Value.Count -gt 0 -and $FilterBy -eq "Id") {
                    if ([String]$Discovery.DiscoveryConfigGroupId -eq $Value){
                        $DiscoveryData = New-DiscoveryFromJson $Discovery
                    }
                }
                elseif ($Value.Count -gt 0 -and $FilterBy -eq "Name") {
                    if ($Discovery.DiscoveryConfigGroupName -eq $Value){
                        $DiscoveryData = New-DiscoveryFromJson $Discovery
                        # OME API allows duplicate discovery job names. We will end up returning the most recent one.
                    }
                }
                else {
                    $DiscoveryData += New-DiscoveryFromJson $Discovery
                }
            }
            return $DiscoveryData
        }
        else {
            Write-Error "Unable to retrieve Discovery list from $($SessionAuth.Host)"
        }
    }
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String)
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

