
function Invoke-OMEResetApplication {
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
   Import directory group and assign to role from directory service

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER DirectoryService
    Object of type AccountProvider returned from Get-OMEDirectoryService commandlet
.PARAMETER DirectoryGroups
    Object of type DirectoryGroup returned from Get-OMEDirectoryServiceSearch commandlet
.PARAMETER Role
    Array of Objects of type Role returned from Get-OMERole commandlet
 .EXAMPLE
   Invoke-OMEDirectoryServiceImportGroup -DirectoryService $(Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL") -DirectoryGroups $(Get-OMEDirectoryServiceSearch -Name "Admin" -DirectoryService $(Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL") -DirectoryType "AD" -UserName "Usename@lab.local" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)) -Role $(Get-OMERole -Name "chassis") -Verbose

   Import directory group
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("RESET_ALL", "RESET_CONFIG")]
    [String]$ResetType,
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

        $ResetApplicationUrl = $BaseUri  + "/api/ApplicationService/Actions/ApplicationService.ResetApplication"
        $Payload ='{
            "ResetType":"RESET_ALL"
           }
        ' | ConvertFrom-Json
        
        $Payload.ResetType = $ResetType
        $Payload = $Payload | ConvertTo-Json -Depth 6
        Write-Verbose $ResetApplicationUrl

        $ResetApplicationResponse = Invoke-WebRequest -Uri $ResetApplicationUrl -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $Payload
        if ($ResetApplicationResponse.StatusCode -in 200, 201, 204) {
            $ResetApplicationData = $ResetApplicationResponse.Content | ConvertFrom-Json
            return $ResetApplicationData   
        } else {
            Write-Error "Reset Application failed..."
            return $false
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}