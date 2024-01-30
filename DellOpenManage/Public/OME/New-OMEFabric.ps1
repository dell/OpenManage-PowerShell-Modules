
function Get-FabricPayload($Name, $Description, $DesignType, $SwitchAServiceTag, $SwitchBServiceTag, $OverrideLLDPConfiguration) {
    $Payload = '{
        "Name": "SmartFabric",
        "Description": "SmartFabric",
        "OverrideLLDPConfiguration": "Disabled",
        "ScaleVLANProfile": "Enabled",
        "FabricDesignMapping": [
            {
                "DesignNode": "Switch-A",
                "PhysicalNode": "CBJXLN2"
            },
            {
                "DesignNode": "Switch-B",
                "PhysicalNode": "F13RPK2"
            }
        ],
        "FabricDesign": {
            "Name": "2xMX9116n_Fabric_Switching_Engines_in_different_chassis"
        }
    }' | ConvertFrom-Json

    $Payload.Name = $Name
    $Payload.Description = $Description
    $Payload.FabricDesign.Name = $DesignType
    $Payload.FabricDesignMapping[0].PhysicalNode = $SwitchAServiceTag
    $Payload.FabricDesignMapping[1].PhysicalNode = $SwitchBServiceTag

    if ($OverrideLLDPConfiguration) {
        $Payload.OverrideLLDPConfiguration = "Enabled"
    }

    $Payload = $Payload | ConvertTo-Json -Depth 6
    return $Payload
}

function Invoke-CheckOMEFabricApplicableNode ($BaseUri, $Headers, $ContentType, $DesignType, $SwitchAServiceTag, $SwitchBServiceTag) {
    $ApplicableNodesURL = $BaseUri + "/api/NetworkService/FabricDesigns('$($DesignType)')/NetworkService.GetApplicableNodes"
    Write-Verbose "Get fabric applicable nodes"
    Write-Verbose $ApplicableNodesURL
    $Response = Invoke-WebRequest -Uri $ApplicableNodesURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $null
    if ($Response.StatusCode -in (200,201)) {
        $SwitchAPass = $false
        $SwitchBPass = $false
        $DesignCriteriaData = $Response | ConvertFrom-Json
        Write-Verbose $($DesignCriteriaData | ConvertTo-Json -Depth 6)
        foreach ($Criteria in $DesignCriteriaData.DesignCriteria) {
            if ($Criteria.Criterion.NodeName -eq "Switch-A") {
                $SwitchACheck = $Criteria.ApplicableNodes | Where-Object { $_.ServiceTag -eq $SwitchAServiceTag }
                if ($SwitchACheck.Count -eq 1)  {
                    $SwitchAPass = $true
                }
            }

            if ($Criteria.Criterion.NodeName -eq "Switch-B") {
                $SwitchBCheck = $Criteria.ApplicableNodes | Where-Object { $_.ServiceTag -eq $SwitchBServiceTag }
                if ($SwitchBCheck.Count -eq 1)  {
                    $SwitchBPass = $true
                }
            }
        }
        if ($SwitchAPass -and $SwitchBPass) {
            return $true
            Write-Verbose "Pass check criterion for fabric applicable nodes"
        } else {
            Write-Verbose "Fail check criterion for fabric applicable nodes. Check your chassis and IOM service tags"
            return $false
        }
    }
    else {
        Write-Warning "Failed to get fabric applicable nodes"
        return $false
    }
}

function New-OMEFabric {
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
   Create an MCM group 

 .DESCRIPTION
   This script uses the OME REST API to create mcm group, find memebers and add the members to the group.

 .PARAMETER FabricName
   The Name of the MCM Fabric.

 .EXAMPLE
   New-OMEFabric -FabricName TestFabric -Wait
.EXAMPLE 
    For more examples visit https://github.com/dell/OpenManage-PowerShell-Modules/blob/main/README.md
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String] $Name,

    [Parameter(Mandatory=$false)]
    [String] $Description,

    [Parameter(Mandatory)]
    [ValidateSet("2xMX9116n_Fabric_Switching_Engines_in_different_chassis", "2xMX9116n_Fabric_Switching_Engines_in_same_chassis", "2xMX5108n_Ethernet_Switches_in_same_chassis")]
    [String]$DesignType,

    [Parameter(Mandatory)]
    [String] $SwitchAServiceTag,
    
    [Parameter(Mandatory)]
    [String] $SwitchBServiceTag,

    [Parameter(Mandatory=$false)]
    [Switch]$OverrideLLDPConfiguration,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

## Script that does the work
if (!$(Confirm-IsAuthenticated)){
    Return
}

Try {
    if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
    $BaseUri = "https://$($SessionAuth.Host)"
    $Headers = @{}
    $Headers."X-Auth-Token" = $SessionAuth.Token
    $ContentType = "application/json"

    $CheckApplicableNodes = Invoke-CheckOMEFabricApplicableNode -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -DesignType $DesignType -SwitchAServiceTag $SwitchAServiceTag -SwitchBServiceTag $SwitchBServiceTag
    if (!$CheckApplicableNodes) {
        throw [System.Exception]::new("FabricException", "Fabric applicable nodes check failed. Check your chassis and IOM service tags.")
    }

    $JobId = 0
    Write-Verbose "Creating fabric"
    $FabricPayload = Get-FabricPayload -Name $Name -Description $Description -DesignType $DesignType -SwitchAServiceTag $SwitchAServiceTag -SwitchBServiceTag $SwitchBServiceTag `
        -OverrideLLDPConfiguration $OverrideLLDPConfiguration
    Write-Verbose $FabricPayload
    $CreateFabricURL = $BaseUri + "/api/NetworkService/Actions/NetworkService.CreateFabric"
    $Response = Invoke-WebRequest -Uri $CreateFabricURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $FabricPayload 
    if ($Response.StatusCode -in (200,201)) {
        $FabricData = $Response | ConvertFrom-Json
        $JobId = $FabricData.JobId
        Write-Verbose "Create fabric job created successfully...JobId is $($JobId)"
    }
    else {
        Write-Warning "Failed to create fabric job"
    }
    if ($JobId -ne 0) {
        Write-Verbose "Created job $($JobId) to create fabric ... Polling status now"
        if ($Wait) {
            $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
            return $JobStatus
        } else {
            return $JobId
        }
    }
    else {
        Write-Error "Unable to track fabric creation .. Exiting" 
    }

}
catch {
    Resolve-Error $_
}

}