
function Get-OMEDirectoryService {
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
   Get-OMEDirectoryServiceSearch -DirectoryType "AD" | Format-Table
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
	[ValidateSet("AD", "LDAP")]
    [String] $DirectoryType = "AD"
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

        $AccountProviderUrl = ""
        if ($DirectoryType -eq "AD") {
            $AccountProviderUrl = $BaseUri  + "/api/AccountService/ExternalAccountProvider/ADAccountProvider"
        } else {
            $AccountProviderUrl = $BaseUri  + "/api/AccountService/ExternalAccountProvider/LDAPAccountProvider"
        }
        $AccountProviders = @()
        Write-Verbose $AccountProviderUrl
        $AccountProviderResponse = Invoke-WebRequest -Uri $AccountProviderUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
        if ($AccountProviderResponse.StatusCode -in 200, 201) {
            $AccountProviderData = $AccountProviderResponse.Content | ConvertFrom-Json
            foreach ($AccountProvider in $AccountProviderData.value) {
                $AccountProviders += New-AccountProviderFromJson -AccountProvider $AccountProvider
            }
        }
        # OData filtering not supported on this API endpoint. Provide basic filtering ability.
        if ($Name) { 
            return $AccountProviders | Where-Object -Property "Name" -Match $Name
        } else {
            return $AccountProviders
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}