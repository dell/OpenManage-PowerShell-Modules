function Get-OMEApplicationSettings {
    <#
Copyright (c) 2023 Dell EMC Corporation

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
    Get Application Settings
.DESCRIPTION
.INPUTS
.EXAMPLE
    Get-OMEApplicationSettings
.EXAMPLE
    Get-OMEApplicationSettings | Select-Object -ExpandProperty SystemConfiguration | Select-Object -ExpandProperty Components | Select-Object -First 1 | Select-Object -ExpandProperty Attributes | Format-Table
    Display all Attributes in Table. See README for more examples.
#>

    [CmdletBinding()]
    param(
    )

    Begin {}
    Process {
        if (!$(Confirm-IsAuthenticated)) {
            Return
        }
        Try {
            if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
            $BaseUri = "https://$($SessionAuth.Host)"
            $Type = "application/json"
            $Headers = @{}
            $Headers."X-Auth-Token" = $SessionAuth.Token

            $JobURL = $BaseUri + "/api/ApplicationService/Actions/ApplicationService.GetConfiguration"
            $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $null
            if ($JobResp.StatusCode -in 200, 201) {
                Write-Verbose "Application settings job submitted successful..."
                $JobInfo = $JobResp.Content | ConvertFrom-Json
                $JobInfo
            }
            else {
                Write-Error "Job creation failed"
            }
        }
        Catch {
            Resolve-Error $_
        }
    }

    End {}

}
