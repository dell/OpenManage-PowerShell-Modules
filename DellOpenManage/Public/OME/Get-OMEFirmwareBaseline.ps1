
using module ..\..\Classes\FirmwareBaseline.psm1

function Get-OMEFirmwareBaseline {
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
    Get firmware baseline from OpenManage Enterprise
.DESCRIPTION
    Returns all baselines if no input received
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="Name", "Id")
.INPUTS
    String[]
.EXAMPLE
    Get-OMEFirmwareBaseline | Format-Table

    Get all baselines
.EXAMPLE
    "AllLatest" | Get-OMEFirmwareBaseline | Format-Table
    
    Get baseline by name
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
        $BaselineUrl   = $BaseUri + "/api/UpdateService/Baselines"
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $BaselineData = @()
        $BaselineResp = Invoke-WebRequest -Uri $BaselineUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($BaselineResp.StatusCode -in 200, 201) {
            $BaselineInfo = $BaselineResp.Content | ConvertFrom-Json
            foreach ($Baseline in $BaselineInfo.'value') {
                if ($Value.Count -gt 0 -and $FilterBy -eq "Id") {
                    if ([String]$Baseline.Id -eq $Value){
                        $BaselineData += New-FirmwareBaselineFromJson $Baseline
                    }
                }
                elseif ($Value.Count -gt 0 -and $FilterBy -eq "Name") {
                    if ($Baseline.Name -eq $Value){
                        $BaselineData += New-FirmwareBaselineFromJson $Baseline
                    }
                }
                else {
                    $BaselineData += New-FirmwareBaselineFromJson $Baseline
                }
            }
            return $BaselineData
        }
        else {
            Write-Error "Unable to retrieve Baseline list from $($SessionAuth.Host)"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}
