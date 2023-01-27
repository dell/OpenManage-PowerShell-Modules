using module ..\..\Classes\Template.psm1
using module ..\..\Classes\IdentityPool.psm1

function Get-TemplateIdentityPoolPayload($TemplateId, $IdentityPoolId) {
    $Payload = '{
        "TemplateId": 13,
        "IdentityPoolId": 0,
        "StrictCheck": false,
        "Attributes": [
            {
                "Attributes": []
            }
        ],
        "VlanAttributes": []
    }' | ConvertFrom-Json

    $Payload.TemplateId = $TemplateId
    $Payload.IdentityPoolId = $IdentityPoolId
    return $Payload
}


function Set-OMETemplateIdentityPool {
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
    Set Identity Pool on a Template
.DESCRIPTION
    Set Identity Pool on a Template
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate
.PARAMETER Template
    Object of type IdentityPool returned from Get-OMEIdentityPool
.INPUTS
    Template
.EXAMPLE
    "MX740c Template" | Get-OMETemplate | Set-OMETemplateIdentityPool -IdentityPool $("default" | Get-OMEIdentityPool) -Verbose

    Set Identity Pool on Template
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Template[]] $Template,

    [Parameter(Mandatory)]
    [IdentityPool] $IdentityPool
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

        $UpdateNetworkConfigPayload = Get-TemplateIdentityPoolPayload -TemplateId $Template.Id -IdentityPoolId $IdentityPool.Id
        $UpdateNetworkConfigURL = $BaseUri + "/api/TemplateService/Actions/TemplateService.UpdateNetworkConfig"
        $UpdateNetworkConfigPayload = $UpdateNetworkConfigPayload | ConvertTo-Json -Depth 6
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