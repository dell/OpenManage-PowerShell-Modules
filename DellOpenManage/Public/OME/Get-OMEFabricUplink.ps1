
using module ..\..\Classes\Fabric.psm1

function Get-OMEFabricUplink {
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
   Get list of fabric uplinks

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER Name
    String containing fabric name to search
.EXAMPLE
    "Uplink01" | Get-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric)

    Get uplink by name
.EXAMPLE
    Get-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric) | Format-Table

    Get all uplinks
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String]$Name,

    [Parameter(Mandatory)]
    [Fabric] $Fabric
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Headers = @{}
        $ContentType = "application/json"
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $UplinkUrl = $BaseUri + "/api/NetworkService/Fabrics('$($Fabric.Id)')/Uplinks"
        $Uplinks = @()
        Write-Verbose $UplinkUrl
        $UplinkResponse = Invoke-WebRequest -Uri $UplinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
        if ($UplinkResponse.StatusCode -in 200, 201) {
            $UplinkData = $UplinkResponse.Content | ConvertFrom-Json
            foreach ($Uplink in $UplinkData.value) {
                # Get uplink ports
                $UplinkPorts = @()
                $UplinkPortsUrl = $BaseUri + "/api/NetworkService/Fabrics('$($Fabric.Id)')/Uplinks('$($Uplink.Id)')/Ports"
                Write-Verbose $UplinkPortsUrl
                $UplinkPortsResponse = Invoke-WebRequest -Uri $UplinkPortsUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
                if ($UplinkPortsResponse.StatusCode -in 200, 201) {
                    $UplinkPortsData = $UplinkPortsResponse.Content | ConvertFrom-Json
                    foreach ($UplinkPort in $UplinkPortsData.value) {
                        $UplinkPorts += $UplinkPort.Id
                    }
                }

                # Get uplink networks
                $UplinkNetworks = @()
                $UplinkNetworksUrl = $BaseUri + "/api/NetworkService/Fabrics('$($Fabric.Id)')/Uplinks('$($Uplink.Id)')/Networks"
                Write-Verbose $UplinkNetworksUrl
                $UplinkNetworksResponse = Invoke-WebRequest -Uri $UplinkNetworksUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
                if ($UplinkNetworksResponse.StatusCode -in 200, 201) {
                    $UplinkNetworksData = $UplinkNetworksResponse.Content | ConvertFrom-Json
                    foreach ($UplinkNetwork in $UplinkNetworksData.value) {
                        $UplinkNetworks += $UplinkNetwork.Id
                    }
                }
                $Uplinks += New-UplinkFromJson -Uplink $Uplink -Ports $UplinkPorts -Networks $UplinkNetworks
            }
        }
        # OData filtering not supported on this API endpoint. Provide basic filtering ability.
        if ($Name) { 
            return $Uplinks | Where-Object -Property "Name" -Match $Name
        } else {
            return $Uplinks
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}