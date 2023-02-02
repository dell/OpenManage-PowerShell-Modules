
function Get-OMEFabric {
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
   Get list of fabrics

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER Name
    String containing fabric name to search
.EXAMPLE
    "SmartFabric01" | Get-OMEFabric | Format-Table

    Get fabric by name
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String]$Name
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

        $FabricUrl = $BaseUri + "/api/NetworkService/Fabrics"
        $Fabrics = @()
        Write-Verbose $FabricUrl
        $FabricResponse = Invoke-WebRequest -Uri $FabricUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
        if ($FabricResponse.StatusCode -in 200, 201) {
            $FabricData = $FabricResponse.Content | ConvertFrom-Json
            foreach ($Fabric in $FabricData.value) {
                $Fabrics += New-FabricFromJson -Fabric $Fabric
            }
        }
        # OData filtering not supported on this API endpoint. Provide basic filtering ability.
        if ($Name) { 
            return $Fabrics | Where-Object -Property "Name" -Match $Name
        } else {
            return $Fabrics
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}