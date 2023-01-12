
function Get-OMERole {
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
   Get list of account roles

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER Name
    String containing name to search by
 .EXAMPLE
   Get-OMERole | Format-Table

   List all account roles
 .EXAMPLE
   Get-OMERole -Name "chassis" | Format-Table

   Search account roles by name
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
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

        $RoleUrl = $BaseUri + "/api/AccountService/Roles"

        $Roles = @()
        Write-Verbose $RoleUrl
        $RoleResponse = Invoke-WebRequest -Uri $RoleUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
        if ($RoleResponse.StatusCode -in 200, 201) {
            $RoleData = $RoleResponse.Content | ConvertFrom-Json
            foreach ($Role in $RoleData.value) {
                $Roles += New-RoleFromJson -Role $Role
            }
        }
        # OData filtering not supported on this API endpoint. Provide basic filtering ability.
        if ($Name) { 
            return $Roles | Where-Object -Property "Name" -Match $Name
        } else {
            return $Roles
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}