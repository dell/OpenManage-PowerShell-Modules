
function Invoke-OMEResetApplication {
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
   This method resets the application. You can either reset only the configuration or clear all the data.

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER ResetType
    Option to reset only the configuration or clear all the data. ("RESET_CONFIG", "RESET_ALL")
 .EXAMPLE
   Invoke-OMEResetApplication -ResetType "RESET_ALL"

   Reset all application data
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("RESET_ALL", "RESET_CONFIG")]
    [String]$ResetType
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
        Write-Verbose $Payload
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