function Get-ApplianceSettingsPayload($Settings) {
    $Payload = '{
        "SystemConfiguration": {
            "Components": [{
                "FQDD": "MM.Embedded.1",
                "Attributes": []
            }]
        }
    }'| ConvertFrom-Json

    foreach ($Setting in $Settings) {
        $Name = $Setting["Name"]
        $Value = $Setting["Value"]
        $Attribute = @{
            "Name" = "${Name}"
            "Value" = $Value
        }
        $Payload.SystemConfiguration.Components[0].Attributes += $Attribute
    }
    return $Payload
}

function Set-OMEApplicationSettings {
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
    Set Application Settings
.DESCRIPTION
.PARAMETER Settings
    Array of PSCustomObject (Hashtable) containing Attributes to set. Use Get-OMEApplicationSettings to view available Attributes. Example: $Settings = @(@{Name="SSH.1#Enable"; Value=$true})
.INPUTS
.EXAMPLE  
    Set-OMEApplicationSettings -Settings @(@{Name="SSH.1#Enable"; Value=$true}) -Wait -Verbose
    Enable SSH. See README for more examples.
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$Settings,

        [Parameter(Mandatory = $false)]
        [Switch]$Wait,

        [Parameter(Mandatory = $false)]
        [int]$WaitTime = 3600
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


            $JobPayload = Get-ApplianceSettingsPayload -Settings $Settings
            # Submit job
            $JobURL = $BaseUri + "/api/ApplicationService/Actions/ApplicationService.ApplyConfiguration"
            $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
            Write-Verbose $JobPayload
            $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
            if ($JobResp.StatusCode -eq 200) {
                Write-Verbose "Application settings job submitted successful..."
                $JobInfo = $JobResp.Content | ConvertFrom-Json
                $JobId = $JobInfo.JobId
                Write-Verbose "Created job $($JobId) successfully..."
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                }
                else {
                    return $JobId
                }
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