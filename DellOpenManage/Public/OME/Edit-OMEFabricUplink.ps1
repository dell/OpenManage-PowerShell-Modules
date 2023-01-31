using module ..\..\Classes\Fabric.psm1
using module ..\..\Classes\Uplink.psm1
using module ..\..\Classes\Network.psm1

function Get-FabricUplinkEditPayload($Name, $Description, $MediaType, $Ports, $NetworkIds, $UnTaggedNetwork, $UplinkFailureDetection, $Uplink, $Mode) {
    $Payload = '{
        "Id": "",
        "Name": "Uplink_Ethernet_Fabric-B",
        "Description": "Ethernet Uplink created from REST.",
        "MediaType": "Ethernet",
        "NativeVLAN": 0,
        "UfdEnable":"Disabled",
        "Ports": [
            {
                "Id": "6ZB1XC2:ethernet1/1/41"
            },
            {
                "Id": "5ZB1XC2:ethernet1/1/41"
            }
        ],
        "Networks": [
            {
                "Id": 95614
            }
        ]
    }' | ConvertFrom-Json

    $Payload.Id = $Uplink.Id
    $Payload.NativeVLAN = $Uplink.NativeVLAN
    # The API requires that we rebuild the payload from the existing values. You can't make a partial update.
    # Only update attributes if value provided, otherwise set them to the existing value. 
    if ($Name) {
        $Payload.Name = $Name
    } else {
        $Payload.Name = $Uplink.Name
    }

    if ($Description) {
        $Payload.Description = $Description
    } else {
        $Payload.Description = $Uplink.Description
    }
    # MediaType is readonly in UI, this cannot be changed
    $Payload.MediaType = $Uplink.MediaType
    
    if ($UplinkFailureDetection) {
        $Payload.UfdEnable = "Enabled"
    }

    if ($null -eq $UnTaggedNetwork) {
        $Payload.NativeVLAN = $Uplink.NativeVLAN
    } else {
        $Payload.NativeVLAN = $UnTaggedNetwork.VlanMaximum
    }

    $PortList = [System.Collections.ArrayList]@()
    # Split $Ports into array by comma and trim whitespace
    $PortSplit = @()
    if ($Ports) {
        $PortSplit = $($Ports.Split(",") | % { $_.Trim() })
    }
    $NetworkList = [System.Collections.ArrayList]@()
    if ($Mode -eq "Append") {
        Write-Host $PortSplit.Count
        if ($PortSplit.Count -gt 0) {
            $PortList += $Uplink.Ports
            # Check to make sure we aren't adding a duplicate
            foreach ($Pv in $PortSplit) {
                if (-not ($PortList -contains $Pv)) {
                    $PortList += $Pv
                }
            }
        } else {
            $PortList = $Uplink.Ports
        }

        if ($NetworkIds.Count -gt 0) {
            $NetworkList += $Uplink.Networks
            # Check to make sure we aren't adding a duplicate
            foreach ($Nv in $NetworkIds) {
                if (-not ($NetworkList -contains $Nv)) {
                    $NetworkList += $Nv
                }
            }
        } else {
            $NetworkList = $Uplink.Networks
        }
    } elseif ($Mode -eq "Replace") {
        if ($PortSplit.Count -gt 0) {
            $PortList = $PortSplit
        } else {
            $PortList = $Uplink.Ports
        }

        if ($NetworkIds.Count -gt 0) {
            $NetworkList = $NetworkIds
        } else {
            $NetworkList = $Uplink.Networks
        }
    } elseif ($Mode -eq "Remove") {
        $PortList = [System.Collections.ArrayList]$Uplink.Ports
        if ($PortSplit.Count -gt 0) {
            # Remove item if in list
            foreach ($Pv in $PortSplit) {
                if ($PortList -contains $Pv) {
                    $PortList.Remove($Pv)
                }
            }
        }

        $NetworkList = [System.Collections.ArrayList]$Uplink.Networks
        if ($NetworkIds.Count -gt 0) {
            foreach ($Nv in $NetworkIds) {
                if ($NetworkList -contains $Nv) {
                    $NetworkList.Remove($Nv)
                }
            }
        } 
    } else {
        $PortList = $Uplink.Ports
        $NetworkList = $Uplink.Networks
    }

    $PortPayloads = @()
    foreach ($Port in $PortList) {
        $PortPayload = '{
            "Id": ""
        }' | ConvertFrom-Json
        $PortPayload.Id = $Port
        $PortPayloads += $PortPayload
    }

    $NetworkPayloads = @()
    foreach ($NetworkId in $NetworkList) {
        $NetworkPayload = '{
            "Id": ""
        }' | ConvertFrom-Json
        $NetworkPayload.Id = $NetworkId
        $NetworkPayloads += $NetworkPayload
    }

    $Payload.Ports = $PortPayloads
    $Payload.Networks = $NetworkPayloads

    $Payload = $Payload | ConvertTo-Json -Depth 6
    return $Payload
}

function Edit-OMEFabricUplink {
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

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String] $Name,

    [Parameter(Mandatory=$false)]
    [String] $Description,

    [Parameter(Mandatory)]
    [Fabric] $Fabric,

    [Parameter(Mandatory)]
    [Uplink] $Uplink,

    [Parameter(Mandatory=$false)]
    [Switch]$UplinkFailureDetection,

    [Parameter(Mandatory=$false)]
    [String] $Ports,
    
    [Parameter(Mandatory=$false)]
    [Network[]] $TaggedNetworks,

    [Parameter(Mandatory=$false)]
    [Network] $UnTaggedNetwork,

    [Parameter(Mandatory=$false)]
	[ValidateSet("Append", "Replace", "Remove")]
    [String] $Mode
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

    $TaggedNetworkIds = @()
    foreach ($Network in $TaggedNetworks) {
        $TaggedNetworkIds += $Network.Id
    }
    if ($TaggedNetworkIds.Length -gt 0) {
        if ($null -eq $Mode) { throw [System.ArgumentNullException] "Mode parameter required when specifing -TaggedNetworks" }
    }
    Write-Verbose "Updating fabric uplink"
    $FabricPayload = Get-FabricUplinkEditPayload -Name $Name -Description $Description -MediaType $UplinkType `
        -Ports $Ports -NetworkIds $TaggedNetworkIds -UnTaggedNetwork $UnTaggedNetwork -UplinkFailureDetection $UplinkFailureDetection `
        -Uplink $Uplink -Mode $Mode
    Write-Verbose $FabricPayload
    $CreateFabricUplinkURL = $BaseUri + "/api/NetworkService/Fabrics('$($Fabric.Id)')/Uplinks('$($Uplink.Id)')"
    Write-Verbose $CreateFabricUplinkURL
    $Response = Invoke-WebRequest -Uri $CreateFabricUplinkURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method PUT -Body $FabricPayload 
    if ($Response.StatusCode -in 200, 201) {
        #$UplinkId = $Response.Content | ConvertFrom-Json
        Write-Verbose "Updated fabric uplink successfully..."
    }
    else {
        Write-Warning "Failed to update fabric uplink"
    }
}
catch {
    Resolve-Error $_
}

}