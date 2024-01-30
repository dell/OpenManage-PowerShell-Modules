
function Get-OMEMXDomain {
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
    Get MX domains (chassis) from OpenManage Enterprise
.DESCRIPTION

.PARAMETER RoleType
    Filter the results by role type (Default="ALL", "LEAD", "BACKUPLEAD", "MEMBER")
.INPUTS
    String
.EXAMPLE
    Get-OMEMXDomain | Format-List
    List all domains
.EXAMPLE
    "LEAD" | Get-OMEMXDomain | Format-List

    List lead chassis
.EXAMPLE
    "BACKUPLEAD" | Get-OMEMXDomain | Format-List
    
    List backup lead chassis
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [ValidateSet("LEAD", "BACKUPLEAD", "MEMBER", "ALL")]
    [String]$RoleType = "ALL"
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
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Members = @()
        $URL = $BaseUri + "/api/ManagementDomainService/Domains"
        $ContentType = "application/json"
        $Response = Invoke-WebRequest -Uri $URL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method GET
        if ($Response.StatusCode -in (200,201)) {
            $DomainResp = $Response.Content | ConvertFrom-Json
            if ($DomainResp."value".Length -gt 0) {
                $MemberDevices = $DomainResp."value"
                If ($RoleType -eq "ALL") {
                    foreach ($Member in $MemberDevices) {
                        $Members += New-DomainFromJson -Domain $Member
                    }
                } else {
                    foreach ($Member in $MemberDevices) {
                        if ($RoleType -eq "LEAD" -and $Member.'DomainRoleTypeValue' -eq "LEAD") {
                            $Members += New-DomainFromJson -Domain $Member 
                        } elseif ($RoleType -eq "MEMBER" -and $Member.'DomainRoleTypeValue' -eq "MEMBER") {
                            $Members += New-DomainFromJson -Domain $Member
                        } elseif ($RoleType -eq "BACKUPLEAD" -and $Member.'BackupLead' -eq $true) {
                            $Members += New-DomainFromJson -Domain $Member
                        }
                    }
                }
            }
            else {
                Write-Warning "No domains discovered"
            }
            return $Members # Workaround for single element array
        }
        else {
            Write-Warning "Failed to get domains and status code returned is $($Response.StatusCode)"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

