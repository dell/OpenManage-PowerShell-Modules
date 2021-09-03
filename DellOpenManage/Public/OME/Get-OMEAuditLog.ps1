function Get-OMEAuditLog {

<#
_author_ = Grant Curell <grant_curell@dell.com>

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
    Retrieves the audit logs from a target OME instance

  .DESCRIPTION
    It performs X-Auth with basic authentication. Note: Credentials are not stored on disk.

  .EXAMPLE
    Get-OMEAuditLog | Format-Table
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

        $AuditLogUrl = $BaseUri  + "/api/ApplicationService/AuditLogs"
        $AuditLogData = @()
        $AuditLogResponse = Get-ApiAllData -BaseUri $BaseUri -Url $AuditLogUrl -Headers $Headers
        foreach ($AuditLog in $AuditLogResponse) {
            $AuditLogData += $AuditLog
        }
        return $AuditLogData
    }
    Catch {
        Resolve-Error $_
    }

}