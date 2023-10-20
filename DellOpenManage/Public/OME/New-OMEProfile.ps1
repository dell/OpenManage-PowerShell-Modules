using module ..\..\Classes\Template.psm1

function New-OMEProfile {
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
    Create new Profile in OpenManage Enterprise
.DESCRIPTION
    Create new Profile in OpenManage Enterprise
.PARAMETER NamePrefix
    Name prefix given to created Profiles
.PARAMETER Description
    Description of Profile
.PARAMETER NumberOfProfilesToCreate
    Number of Profiles to create
.PARAMETER NetworkBootShareType
    Share type ("NFS", "CIFS")
.PARAMETER NetworkBootShareIpAddress
    IP Address of the share server
.PARAMETER NetworkBootIsoPath
    Full path to the ISO
.PARAMETER NetworkBootIsoTimeout
    Lifecycle Controller timeout setting (Default=1) Hour
.PARAMETER NetworkBootShareName
    Share name (CIFS Only)
.PARAMETER NetworkBootShareUser
    Share user (CIFS Only)
.PARAMETER NetworkBootShareWorkGroup
    Share workgroup (CIFS Only)
.PARAMETER NetworkBootSharePassword
    Share password (CIFS Only)
.INPUTS
    [Template] Template
.EXAMPLE
    New-OMEProfile -Name "Test Profile 01"
    
    Create a new static Profile
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Template]$Template,

    [Parameter(Mandatory)]
    [String]$NamePrefix,

    [Parameter(Mandatory=$false)]
    [String]$Description,

    [Parameter(Mandatory)]
    [Int]$NumberOfProfilesToCreate,

    [Parameter(Mandatory=$false)]
    [ValidateSet("CIFS", "NFS")]
    [String]$NetworkBootShareType,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareIpAddress,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootIsoPath,

    [Parameter(Mandatory=$false)]
    [Int]$NetworkBootIsoTimeout = 1,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareName,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareUser,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareWorkGroup,

    [Parameter(Mandatory=$false)]
    [SecureString]$NetworkBootSharePassword
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $ProfileURL = $BaseUri + "/api/ProfileService/Profiles"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $ProfilePayload = '{
            "TemplateId": 10,
            "NamePrefix": "Profile01",
            "Description": "",
            "NumberOfProfilesToCreate":3,
            "NetworkBootToIso":{
                "BootToNetwork":false,
                "ShareType":"CIFS",
                "ShareDetail":{
                    "IpAddress":"",
                    "ShareName":"",
                    "WorkGroup":"",
                    "User":"",
                    "Password":""
                },
                "IsoPath":"abc.iso",
                "IsoTimeout": 4
            }
        }' | ConvertFrom-Json
        $ProfilePayload.TemplateId = $Template.Id
        $ProfilePayload.NamePrefix = $NamePrefix
        $ProfilePayload.Description = $Description
        $ProfilePayload.NumberOfProfilesToCreate = $NumberOfProfilesToCreate 
        if ($NetworkBootShareType -ne "") {
            # Manually throw exceptions when required parameters are empty since this is an optional subset of parameters
            if (!$NetworkBootShareIpAddress) { throw [System.ArgumentNullException] "NetworkBootShareIpAddress" }
            if (!$NetworkBootIsoPath) { throw [System.ArgumentNullException] "NetworkBootIsoPath" }
            if ($NetworkBootShareType -eq "CIFS"){
                if (!$NetworkBootShareName) { throw [System.ArgumentNullException] "NetworkBootShareName" }
                if (!$NetworkBootShareUser) { throw [System.ArgumentNullException] "NetworkBootShareUser" }
                if (!$NetworkBootSharePassword) { throw [System.ArgumentNullException] "NetworkBootSharePassword" }
            }
            $ProfilePayload.NetworkBootToIso.BootToNetwork = $true
            $ProfilePayload.NetworkBootToIso.ShareType = $NetworkBootShareType
            $ProfilePayload.NetworkBootToIso.IsoPath = $NetworkBootIsoPath
            $ProfilePayload.NetworkBootToIso.IsoTimeout = $NetworkBootIsoTimeout
            $ProfilePayload.NetworkBootToIso.ShareDetail.IpAddress = $NetworkBootShareIpAddress
            $ProfilePayload.NetworkBootToIso.ShareDetail.ShareName = $NetworkBootShareName
            $ProfilePayload.NetworkBootToIso.ShareDetail.User = $NetworkBootShareUser
            $ProfilePayload.NetworkBootToIso.ShareDetail.WorkGroup = $NetworkBootShareWorkGroup
            if ($null -ne $NetworkBootSharePassword) {
                $NetworkBootSharePasswordText = (New-Object PSCredential "user", $NetworkBootSharePassword).GetNetworkCredential().Password
                $ProfilePayload.NetworkBootToIso.ShareDetail.Password = $NetworkBootSharePasswordText
            }
        }

        $ProfilePayload = $ProfilePayload | ConvertTo-Json -Depth 6
        Write-Verbose $ProfilePayload
        $ProfileResponse = Invoke-WebRequest -Uri $ProfileURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $ProfilePayload
        Write-Verbose "Creating Profile..."
        if ($ProfileResponse.StatusCode -eq 201) {
            return $ProfileResponse.Content | ConvertFrom-Json
        }
        else {
            Write-Error "Profile creation failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

