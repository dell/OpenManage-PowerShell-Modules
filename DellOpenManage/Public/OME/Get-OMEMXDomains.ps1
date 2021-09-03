
function Get-OMEMXDomains {
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
    Get-OMEMXDomains | Format-List
    List all domains
.EXAMPLE
    "LEAD" | Get-OMEMXDomains | Format-List

    List lead chassis
.EXAMPLE
    "BACKUPLEAD" | Get-OMEMXDomains | Format-List
    
    List backup lead chassis
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [ValidateSet("LEAD", "BACKUPLEAD", "MEMBER", "ALL")]
    [String]$RoleType = "ALL"
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

    return Get-MXDomains -BaseUri $BaseUri -Headers $Headers -RoleType $RoleType
}
Catch {
    Resolve-Error $_
}

}

