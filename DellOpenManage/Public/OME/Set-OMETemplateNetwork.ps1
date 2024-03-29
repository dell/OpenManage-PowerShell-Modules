﻿using module ..\..\Classes\Template.psm1
using module ..\..\Classes\IdentityPool.psm1
using module ..\..\Classes\Network.psm1

function Get-TemplateVlanPayload($Template, $NICIdentifier, $Port, $TaggedNetworkIds, $UnTaggedNetworkId, $VlanPortMap, $PropagateVlan, $Mode) {
    $Payload = '{
        "TemplateId": 13,
        "IdentityPoolId": 0,
        "PropagateVlan": true,
        "StrictCheck": false,
        "Attributes": [
            {
                "Attributes": []
            }
        ],
        "VlanAttributes": []
    }' | ConvertFrom-Json

    $VlanAttribute = '{
        "ComponentId": 13,
        "Untagged": 0,
        "Tagged": [
            10183
        ]
    }' | ConvertFrom-Json

    <# 
        Get the port and vlans that match the params passed in the commandlet.
        We could set the vlans for multiple ports at the same time here but Port 1 and Port 2 will have different vlans in environments with FC/FCoE 
            Decided to simplify the input params instead of requiring a complex object mapping ports to vlans
    #>
    $VlanPort = $VlanPortMap | Where-Object { $_.NICIdentifier -eq $NICIdentifier -and $_.Port -eq $Port }
    
    $VlanAttribute.ComponentId = $VlanPort.CustomId

    $NetworkSplit = $VlanPort.VlanTagged
    $NetworkList = [System.Collections.ArrayList]@()
    if ($Mode -eq "Append") {
        if ($TaggedNetworkIds.Count -gt 0) {
            $NetworkList += $NetworkSplit
            # Check to make sure we aren't adding a duplicate
            foreach ($Nv in $TaggedNetworkIds) {
                if (-not ($NetworkList -contains $Nv)) {
                    $NetworkList += $Nv
                }
            }
        } else {
            $NetworkList = $NetworkSplit
        }

        if ($null -ne $UnTaggedNetworkId) {
            $VlanAttribute.Untagged = $UnTaggedNetworkId
        } else {
            $VlanAttribute.Untagged = $VlanPort.VlanUnTagged
        }
    } elseif ($Mode -eq "Replace") {
        if ($TaggedNetworkIds.Count -gt 0) {
            $NetworkList = $TaggedNetworkIds
        } else {
            $NetworkList = $NetworkSplit
        }

        if ($null -ne $UnTaggedNetworkId) {
            $VlanAttribute.Untagged = $UnTaggedNetworkId
        } else {
            $VlanAttribute.Untagged = $VlanPort.VlanUnTagged
        }
    } elseif ($Mode -eq "Remove") {
        $NetworkList = [System.Collections.ArrayList]$NetworkSplit
        if ($TaggedNetworkIds.Count -gt 0) {
            foreach ($Nv in $TaggedNetworkIds) {
                if ($NetworkList -contains $Nv) {
                    $NetworkList.Remove($Nv)
                }
            }
        }
        
        if ($null -ne $UnTaggedNetworkId) {
            if ($VlanAttribute.Untagged -eq $UnTaggedNetworkId) {
                $VlanAttribute.Untagged = 0
            }
        } else {
            $VlanAttribute.Untagged = $VlanPort.VlanUnTagged
        }
    } else {
        $NetworkList = $NetworkSplit
        $VlanAttribute.Untagged = $VlanPort.VlanUnTagged
    }

    $VlanAttribute.Tagged = $NetworkList
    $Payload.TemplateId = $Template.Id
    $Payload.IdentityPoolId = $Template.IdentityPoolId
    $Payload.PropagateVlan = $PropagateVlan
    $Payload.VlanAttributes += $VlanAttribute
    return $Payload
}

function Set-OMETemplateNetwork {
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
    Configure Tagged and UnTagged Networks on a Template
.DESCRIPTION
    Configure Tagged and UnTagged Networks on a Template
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate
.PARAMETER NICIdentifier
    String identifing the NIC (Example: "NIC in Mezzanine 1A")
.PARAMETER Port
    Integer identifing the Port number (Example: 1)
.PARAMETER TaggedNetworks
    Array of type Network returned from Get-OMENetwork function.
.PARAMETER UnTaggedNetwork
    Object of type Network returned from Get-OMENetwork function. In most instances we want to omit this parameter. The Untagged network will default to VLAN 1.
.PARAMETER PropagateVlan
    Boolean value that will determine if VLAN settings are propagated immediately without having to re-deploy the template (Default=$true)
.PARAMETER Mode
    String specifing operation to perform on TaggedNetworks and UnTaggedNetwork, required with -TaggedNetworks or -UnTaggedNetwork ("Append", "Replace", "Remove")
.INPUTS
    Template
.EXAMPLE
    "MX740c Template" | Get-OMETemplate | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 1 -TaggedNetworks $("VLAN 1001", "VLAN 1003", "VLAN 1004", "VLAN 1005" | Get-OMENetwork) -Verbose

    Set tagged networks on NIC port 1
.EXAMPLE 
    For more examples visit https://github.com/dell/OpenManage-PowerShell-Modules/blob/main/README.md
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Template[]] $Template,

    [Parameter(Mandatory=$false)]
    [String] $NICIdentifier,

    [Parameter(Mandatory=$false)]
    [int] $Port,

    [Parameter(Mandatory=$false)]
    [Network[]] $TaggedNetworks,

    [Parameter(Mandatory=$false)]
    [Network] $UnTaggedNetwork,

    [Parameter(Mandatory=$false)]
    [Boolean]$PropagateVlan = $true,

    [Parameter(Mandatory=$false)]
	[ValidateSet("Append", "Replace", "Remove")]
    [String] $Mode = "Append"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $TaggedNetworkIds = @()
        foreach ($Network in $TaggedNetworks) {
            $TaggedNetworkIds += $Network.Id
        }
        if ($null -eq $UnTaggedNetwork) {
            $UnTaggedNetworkId = $null
        } else {
            $UnTaggedNetworkId = $UnTaggedNetwork.Id
        }
        # Get network port and vlan info from existing template
        $VlanPortMap = Get-OMETemplateNetwork -Template $Template
        Write-Verbose "Current template network config"
        Write-Verbose $($VlanPortMap | ConvertTo-Json)
        $UpdateNetworkConfigPayload = Get-TemplateVlanPayload -Template $Template -NICIdentifier $NICIdentifier -Port $Port `
            -TaggedNetworkIds $TaggedNetworkIds -UnTaggedNetworkId $UnTaggedNetworkId -VlanPortMap $VlanPortMap -PropagateVlan $PropagateVlan -Mode $Mode
        $UpdateNetworkConfigURL = $BaseUri + "/api/TemplateService/Actions/TemplateService.UpdateNetworkConfig"
        $UpdateNetworkConfigPayload = $UpdateNetworkConfigPayload | ConvertTo-Json -Depth 6
        Write-Verbose "New template network config"
        Write-Verbose $UpdateNetworkConfigPayload
        $UpdateNetworkConfigResp = Invoke-WebRequest -Uri $UpdateNetworkConfigURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $UpdateNetworkConfigPayload
        if ($UpdateNetworkConfigResp.StatusCode -in 200, 201) {
            Write-Verbose "Update template network config successful..."
            
        }
        else {
            Write-Error "Update template network config failed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}