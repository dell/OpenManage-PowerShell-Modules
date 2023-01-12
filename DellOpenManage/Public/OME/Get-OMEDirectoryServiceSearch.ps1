using module ..\..\Classes\AccountProvider.psm1

function Get-OMEDirectoryServiceSearch {
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
   Search a directory service for groups

 .DESCRIPTION
   This script uses the OME REST API.
   Note that the credentials entered are not stored to disk.
.PARAMETER Name
    String containing group name to search
.PARAMETER DirectoryService
    Object of type AccountProvider returned from Get-OMEDirectoryService commandlet
.PARAMETER DirectoryType
    Directory type (Default="AD", "LDAP")
.PARAMETER UserName
    Username to login to the Directory Service
.PARAMETER Password
    Password to login to the Directory Service
.EXAMPLE
   Get-OMEDirectoryServiceSearch -Name "Admin" -DirectoryService $(Get-OMEDirectoryService -DirectoryType "AD" -Name "LAB.LOCAL") -DirectoryType "AD" -UserName "UserName@lab.local" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Verbose | Format-Table
#>   

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    $Name,

    [Parameter(Mandatory)]
    [AccountProvider]$DirectoryService,

    [Parameter(Mandatory=$false)]
	[ValidateSet("AD", "LDAP")]
    [String] $DirectoryType = "AD",

    [Parameter(Mandatory)]
    [String]$UserName,

    [Parameter(Mandatory)]
    [SecureString]$Password
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

        $AccountProviderSearchUrl = $BaseUri  + "/api/AccountService/ExternalAccountProvider/Actions/ExternalAccountProvider.SearchGroups"
        $SearchPayload ='{
            "DirectoryServerId": 0,
            "Type": "AD",
            "UserName": "Administrator@ngmdev.com",
            "Password": "dell@123",
            "CommonName": "Admin"
           }' | ConvertFrom-Json
        
        $SearchPayload.DirectoryServerId = $DirectoryService.Id
        $SearchPayload.Type = $DirectoryType
        $SearchPayload.UserName = $UserName
        $PasswordText = (New-Object PSCredential "user", $Password).GetNetworkCredential().Password
        $SearchPayload.Password = $PasswordText
        $SearchPayload.CommonName = $Name
        $SearchPayload = $SearchPayload | ConvertTo-Json -Depth 6
        Write-Verbose $SearchPayload
        Write-Verbose $AccountProviderSearchUrl

        $SearchResult = @()
        $AccountProviderSearchResponse = Invoke-WebRequest -Uri $AccountProviderSearchUrl -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $SearchPayload
        if ($AccountProviderSearchResponse.StatusCode -in 200, 201) {
            $AccountProviderSearchData = $AccountProviderSearchResponse.Content | ConvertFrom-Json
            foreach ($SearchData in $AccountProviderSearchData) {
                $SearchResult += New-DirectoryGroupFromJson -DirectoryGroup $SearchData
            }
            return $SearchResult
        }
    }
    Catch {
        Resolve-Error $_
    }

}

End {}

}