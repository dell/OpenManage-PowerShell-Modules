
function Get-OMEWarranty {
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
        Get users from OpenManage Enterprise
    .DESCRIPTION
    
    .PARAMETER Value
        String containing search value. Use with -FilterBy parameter
    .PARAMETER FilterBy
        Filter the results by ("Id", Default="UserName", "RoleId")
    .INPUTS
        String[]
    .EXAMPLE
        Get-OMEWarranty | Format-Table

        List all warranty details
    #>
    
    [CmdletBinding()]
    param(
    )
    
    if(!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        Break
        Return
    }

    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $WarrantyUrl = $BaseUri  + "/api/WarrantyService/Warranties"
        $WarrantyData = @()
        $WarrantyResponse = Get-ApiAllData -BaseUri $BaseUri -Url $WarrantyUrl -Headers $Headers
        foreach ($Warranty in $WarrantyResponse) {
            $WarrantyData += $Warranty
        }
        return $WarrantyData
    }
    Catch {
        Resolve-Error $_
    }
    
}
    