using module ..\..\Classes\SessionAuth.psm1
function Disconnect-OMEServer {
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
   Disconnect from OpenManage Enterprise Server using REST API

 .DESCRIPTION

   Deletes the current authentication session

 .EXAMPLE
    Disconnect-OMEServer
#>
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
            $Headers     = @{}
            $Headers."X-Auth-Token" = $SessionAuth.Token
            $SessionUrl = "https://$($SessionAuth.Host)/api/SessionService/Sessions('$($SessionAuth.Id)')"
            $Type = "application/json"
            $SessResponse = Invoke-WebRequest -Uri $SessionUrl -Method Delete -Headers $Headers -ContentType $Type
            if ($SessResponse.StatusCode -eq 204) {
                $Script:SessionAuth = [SessionAuth]::new()
            }
        } 
    Catch {
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}