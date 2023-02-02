using module ..\..\Classes\Fabric.psm1
using module ..\..\Classes\Uplink.psm1

function Remove-OMEFabricUplink {
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
    Remove uplink
.DESCRIPTION
    Remove uplink
 .PARAMETER Fabric
    Object of type Fabric returned from Get-OMEFabric
 .PARAMETER Uplink
    Object of type Uplink returned from Get-OMEFabricUplink
.INPUTS
    Uplink
.EXAMPLE
    Remove-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric) -Uplink $("EthernetUplink01" | Get-OMEFabricUplink -Fabric $("SmartFabric01" | Get-OMEFabric))
    
    Remove uplink
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [Fabric] $Fabric,

    [Parameter(Mandatory, ValueFromPipeline)]
    [Uplink] $Uplink
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $RemoveUrl = $BaseUri + "/api/NetworkService/Fabrics('$($Fabric.Id)')/Uplinks('$($Uplink.Id)')"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        Write-Verbose $RemoveUrl
        $GroupResponse = Invoke-WebRequest -Uri $RemoveUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method DELETE
        Write-Verbose "Removing uplink..."
        if ($GroupResponse.StatusCode -eq 204) {
            Write-Verbose "Remove uplink successful..."
        }
        else {
            Write-Error "Remove uplink failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

