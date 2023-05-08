function New-OMEAlertPolicy {
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
    Create New Alert Policy
.DESCRIPTION
.PARAMETER AlertPolicy
    JSON string containg alert policy. Reference an existing policy with Get-OMEAlertPolicy | ConvertTo-Json -Depth 10
.INPUTS
    String
.EXAMPLE
    New-OMEAlertPolicy -AlertPolicy $NewAlertPolicy

    See README for more examples
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$AlertPolicy
    )

    Begin {}
    Process {
        if (!$(Confirm-IsAuthenticated)) {
            Return
        }
        Try {
            if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
            $BaseUri = "https://$($SessionAuth.Host)"
            $JobUrl = $BaseUri + "/api/AlertService/AlertPolicies"
            $Type = "application/json"
            $Headers = @{}
            $Headers."X-Auth-Token" = $SessionAuth.Token

            $AlertPolicyPayload = $AlertPolicy
            Write-Verbose $AlertPolicyPayload
            $AlertPolicyResponse = Invoke-WebRequest -Uri $JobUrl -UseBasicParsing -Method Post -Body $AlertPolicyPayload -ContentType $Type -Headers $Headers
            $AlertPolicyData = $AlertPolicyResponse.Content | ConvertFrom-Json
            if ($AlertPolicyResponse.StatusCode -eq 201) {
                Write-Verbose $AlertPolicyData
            }
        } 
        Catch {
            Resolve-Error $_
        }
    }

    End {}

}

