using module ..\..\Classes\AlertPolicy.psm1

function Get-AlertPolicyDisablePayload ($Name, $AlertPolicyIds) {
    $Payload = '{
        "AlertPolicyIds": [100,200,300]
    }' | ConvertFrom-Json

    $Payload.AlertPolicyIds = $AlertPolicyIds
    return $Payload
}

function Disable-OMEAlertPolicy {
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
    Enable Alert Policy
.DESCRIPTION
.PARAMETER AlertPolicy
    Object of type AlertPolicy returned from Get-OMEAlertPolicy
.INPUTS
    AlertPolicy
.EXAMPLE
    17758 | Get-OMEAlertPolicy | Disable-OMEAlertPolicy
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AlertPolicy[]]$AlertPolicy
    )

    Begin {}
    Process {
        if (!$(Confirm-IsAuthenticated)) {
            Return
        }
        Try {
            if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
            $BaseUri = "https://$($SessionAuth.Host)"
            $JobUrl = $BaseUri + "/api/AlertService/Actions/AlertService.DisableAlertPolicies"
            $Type = "application/json"
            $Headers = @{}
            $Headers."X-Auth-Token" = $SessionAuth.Token

            $AlertPolicyIds = @()
            foreach ($AlertPolicyItem in $AlertPolicy) {
                $AlertPolicyIds += $AlertPolicyItem.Id
            }
            if ($AlertPolicyIds.Count -gt 0) {
                $AlertPolicyEnablePayload = Get-AlertPolicyDisablePayload -AlertPolicyIds $AlertPolicyIds
                $AlertPolicyEnablePayload = $AlertPolicyEnablePayload | ConvertTo-Json -Depth 6
                Write-Verbose $AlertPolicyEnablePayload
                $AlertPolicyEnableResponse = Invoke-WebRequest -Uri $JobUrl -UseBasicParsing -Method Post -Body $AlertPolicyEnablePayload -ContentType $Type -Headers $Headers
                $AlertPolicyEnableData = $AlertPolicyEnableResponse.Content | ConvertFrom-Json
                if ($null -ne $AlertPolicyEnableData) {
                    Write-Verbose $AlertPolicyEnableData
                }
            } 
            else {
                throw [System.Exception]::new("Exception", "Must specify an Alert Policy")
            }
        } 
        Catch {
            Resolve-Error $_
        }
    }

    End {}

}

