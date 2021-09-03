
function Get-OMENetwork {
<#
Copyright (c) 2021 Dell EMC Corporation

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
   Get list of networks (VLAN) from OME

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter. Supports regex based matching.
.PARAMETER FilterBy
    Filter the results by (Default="Name", "Id", "VlanMaximum", "VlanMinimum", "Type")
 .EXAMPLE
   Get-OMENetwork | Format-Table
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    $Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id", "VlanMaximum", "VlanMinimum", "Type")]
    [String]$FilterBy = "Name"
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
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $NetworkUrl = $BaseUri  + "/api/NetworkConfigurationService/Networks"
        $NetworkData = @()
        $NetworkResponse = Get-ApiAllData -BaseUri $BaseUri -Url $NetworkUrl -Headers $Headers
        foreach ($Network in $NetworkResponse) {
            $NetworkData += New-NetworkFromJson -Network $Network
        }
        # OData filtering not supported on this API endpoint. Provide basic filtering ability.
        if ($Value.Count -gt 0) { 
            return $NetworkData | Where-Object -Property $FilterBy -Match $Value
        } else {
            return $NetworkData
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}