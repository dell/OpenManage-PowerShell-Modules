using module ..\..\Classes\Device.psm1
using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Template.psm1
using module ..\..\Classes\ConfigurationBaseline.psm1

function Invoke-OMEConfigurationBaselineRefresh {
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
    Check or refresh compliance for a configuration baseline
.DESCRIPTION
    A baseline is used to compare configuration against a template
.PARAMETER Baseline
    Object of type ConfigurationBaseline returned from Get-OMEConfigurationBaseline function
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    ConfigurationBaseline
.EXAMPLE
    $("TestBaseline01" | Get-OMEConfigurationBaseline -FilterBy "Name") | Invoke-OMEConfigurationBaselineRefresh -Wait -Verbose
    Refresh compliance for configuration baseline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [ConfigurationBaseline]$Baseline,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

Begin {
    if(!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        Break
        Return
    }
}
Process {
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $payload = '{
            "Id": 1,
            "Name": "Factory Baseline1",
            "Description": "Factory test1",
            "TemplateId": 1104,
            "BaselineTargets": [
                {
                    "Id":"target_id",
                    "Type": {
                        "Id": "target_type",
                        "Name": "target_name"
                    }
                }
            ]
        }' | ConvertFrom-Json
        $TargetPayload = '{
            "Id":"target_id",
            "Type": {
                "Id": "target_type",
                "Name": "target_name"
            }
        }' | ConvertFrom-Json
        $Targets = @()
        foreach ($Target in ,$Baseline.BaselineTargets) {
            $TargetPayload.Id = $Target.Id
            $TargetPayload.Type.Id = $Target.Type.Id
            $TargetPayload.Type.Name = $Target.Type.Name
            $Targets += $TargetPayload
        }
        $payload."BaselineTargets" = $Targets
        $payload."Name" = $Baseline.Name
        $payload."Description" = $Baseline.Description
        $payload."Id" = $Baseline.Id
        $payload."TemplateId" = $Baseline.TemplateId
        $BaselinePayload = $payload

        $BaselineURL = $BaseUri + "/api/TemplateService/Baselines($($Baseline.Id))"
        $BaselinePayload = $BaselinePayload | ConvertTo-Json -Depth 6
        Write-Verbose $BaselinePayload
        $BaselineResponse = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method PUT -Body $BaselinePayload
        if ($BaselineResponse.StatusCode -eq 200) {
            $BaselineData = $BaselineResponse.Content | ConvertFrom-Json
            Write-Verbose $BaselineData
            if ($Wait) {
                $JobStatus = $($BaselineData.Id | Wait-OnConfigurationBaseline -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $BaselineData.Id
            }
            Write-Verbose "Baseline check successful..."
        }
        else {
            Write-Error "Baseline check failed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

