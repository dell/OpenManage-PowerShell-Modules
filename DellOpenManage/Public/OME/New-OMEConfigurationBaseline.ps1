using module ..\..\Classes\Device.psm1
using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Template.psm1
using module ..\..\Classes\ConfigurationBaseline.psm1

function New-OMEConfigurationBaseline {
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
    Create new configuration baseline in OpenManage Enterprise
.DESCRIPTION
    A baseline is used to compare configuration against a template
.PARAMETER Name
    Name of baseline
.PARAMETER Description
    Description of baseline
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate function
.PARAMETER Group
    Object of type Group returned from Get-OMEGroup function
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    New-OMEConfigurationBaseline -Name "TestBaseline01" -Template $("Template01" | Get-OMETemplate -FilterBy "Name") -Devices $("37KPZZZ" | Get-OMEDevice -FilterBy "ServiceTag") -Wait -Verbose
    
    Create new configuration compliance baseline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [String]$Description,

    [Parameter(Mandatory)]
    [Template]$Template,

    [Parameter(Mandatory=$false)]
    [Group]$Group,

    [Parameter(Mandatory=$false)]
    [Device[]]$Devices,

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

        $TargetArray = @()
        if ($Devices.Count -gt 0) {
            $TargetTypeHash = @{
                Id = 1000
                Name = "DEVICE"
            }
            foreach ($Device in $Devices) {
                $TargetTempHash = @{
                    Id = $Device.Id
                    Type = $TargetTypeHash
                }
                $TargetArray += $TargetTempHash
            }
        }
        elseif ($Group) {
            $TargetTypeHash = @{
                Id = 2000
                Name = "GROUP"
            }
            $TargetTempHash = @{
                Id = $Group.Id
                Type = $TargetTypeHash
            }
            $TargetArray += $TargetTempHash
        }
        $payload."BaselineTargets" = $TargetArray
        $payload."Name" = $Name
        $payload."Description" = $Description
        # Throw error if template is not type compliance
        if ($Template.ViewTypeId -ne 1) { throw [System.Exception] "Template must be of type Configuration not Deployment" }
        $payload."TemplateId" = $Template.Id
        $BaselinePayload = $payload

        $BaselineURL = $BaseUri + "/api/TemplateService/Baselines"
        $BaselinePayload = $BaselinePayload | ConvertTo-Json -Depth 6
        Write-Verbose $BaselinePayload
        $BaselineResponse = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $BaselinePayload
        if ($BaselineResponse.StatusCode -eq 201) {
            $BaselineData = $BaselineResponse.Content | ConvertFrom-Json
            Write-Verbose $BaselineData
            if ($Wait) {
                $JobStatus = $($BaselineData.Id | Wait-OnConfigurationBaseline -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $BaselineData.Id
            }
            Write-Verbose "Baseline creation successful..."
        }
        else {
            Write-Error "Baseline creation failed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

